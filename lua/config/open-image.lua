-- Open the image under the cursor in the OS image viewer.
--
-- Deliberately not a plugin and deliberately not inline rendering: drawing
-- images in the terminal needs sixel or the kitty graphics protocol, and under
-- Windows Terminal both are either missing or fragile enough that the images
-- flicker, bleed past the statusline, or silently vanish. Handing the file to
-- the system viewer is one keystroke and always looks right.
--
-- Neovim ships `vim.ui.open()`, which dispatches similarly, but it is a poor
-- fit here on two counts:
--
--   * It probes with `vim.fn.executable()`. Under WSL that walks the Windows
--     half of $PATH over the 9p mount at ~100 ms per miss (see AGENTS.md).
--   * On WSL it hands `explorer.exe` the Linux path verbatim. explorer reads
--     that as a Windows path, so `/home/eren/a.png` becomes `C:\home\eren\a.png`
--     and nothing opens.
--
-- So the dispatch lives here: absolute-path probes via `vim.uv.fs_stat`, and
-- `wslpath -w` conversion before anything on the Windows side sees the file.

local M = {}

-- Only consulted for the bare-path fallback, where there is no `![](...)` to
-- prove the word under the cursor was meant as an image.
local IMAGE_EXTENSIONS = {
  apng = true, avif = true, bmp = true, gif = true, heic = true, heif = true,
  ico = true, jfif = true, jpeg = true, jpg = true, png = true, svg = true,
  tif = true, tiff = true, webp = true,
}

local function exists(path)
  return path ~= nil and vim.uv.fs_stat(path) ~= nil
end

local function first_existing(paths)
  for _, path in ipairs(paths) do
    if exists(path) then return path end
  end
end

--------------------------------------------------------------------------------
-- Finding the target
--------------------------------------------------------------------------------

-- Inline markdown links, image or not: `![alt](target)` and `[text](target)`.
-- The capture is everything inside the parentheses because CommonMark allows a
-- trailing title there -- `(path "a title")` -- which is stripped below.
local LINK_PATTERN = "!?%[[^%]]*%]%(([^%)]*)%)"

-- `<img src="...">`, since markdown files routinely fall back to raw HTML for
-- anything needing a width attribute.
local PATTERNS = { LINK_PATTERN, 'src%s*=%s*"([^"]*)"', "src%s*=%s*'([^']*)'" }

---Every link on a line, with the byte span it occupies.
---@return { first: integer, last: integer, target: string }[]
local function links_in(line)
  local found = {}
  for _, pattern in ipairs(PATTERNS) do
    local init = 1
    while true do
      local first, last, target = line:find(pattern, init)
      if not first then break end
      found[#found + 1] = { first = first, last = last, target = target }
      init = last + 1
    end
  end
  table.sort(found, function(a, b) return a.first < b.first end)
  return found
end

---Strip CommonMark decoration from the parenthesised part of a link.
local function clean_target(target)
  target = vim.trim(target)
  -- `(<path with spaces.png>)` -- the escape hatch for paths markdown would
  -- otherwise mis-tokenise.
  target = target:match("^<(.*)>$") or target
  -- `(path "title")`. Guarded on the quote so a bare path containing spaces is
  -- left intact rather than truncated at the first one.
  target = target:gsub("%s+[\"'(].*$", "")
  -- Editors that insert links tend to percent-encode spaces.
  target = vim.trim(target):gsub("%%20", " ")
  return target
end

---The link under the cursor, else the first one on the line.
---@return string|nil
local function target_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 0-indexed byte -> 1-indexed

  local links = links_in(line)
  if #links == 0 then
    -- No link syntax: fall back to the filename under the cursor. `<cfile>`
    -- respects 'isfname', so it already handles the awkward characters.
    local cfile = vim.fn.expand("<cfile>")
    if cfile == "" then return nil end
    local extension = cfile:lower():match("%.([%w]+)$")
    return IMAGE_EXTENSIONS[extension] and cfile or nil
  end

  for _, link in ipairs(links) do
    if col >= link.first and col <= link.last then return clean_target(link.target) end
  end
  return clean_target(links[1].target)
end

--------------------------------------------------------------------------------
-- Resolving it to something openable
--------------------------------------------------------------------------------

local function is_url(target)
  return target:match("^%a[%w+.-]*://") ~= nil or target:match("^www%.") ~= nil
end

---@return string|nil path, string|nil err
local function resolve(target)
  if target:sub(1, 1) == "~" then
    target = vim.fs.normalize(target)
  end

  if target:sub(1, 1) == "/" then
    return exists(target) and target or nil, ("no such file: %s"):format(target)
  end

  -- Relative links are relative to the file that contains them; falling back to
  -- :pwd covers buffers with no name and links written against the project root.
  local buffer_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local candidates = {}
  if buffer_dir ~= "" and buffer_dir ~= "." then
    candidates[#candidates + 1] = vim.fs.normalize(buffer_dir .. "/" .. target)
  end
  candidates[#candidates + 1] = vim.fs.normalize(vim.fn.getcwd() .. "/" .. target)

  local found = first_existing(candidates)
  if found then return found end
  return nil, ("no such file: %s"):format(candidates[1])
end

--------------------------------------------------------------------------------
-- Handing it to the platform
--------------------------------------------------------------------------------

local function is_wsl()
  -- Set by WSL itself in every distro shell; the /run/WSL probe covers the
  -- stripped-environment case (systemd units, `env -i`).
  return vim.env.WSL_DISTRO_NAME ~= nil or vim.env.WSL_INTEROP ~= nil or exists("/run/WSL")
end

---Translate a Linux path to the form the Windows side expects: `C:\...` under
---/mnt, `\\wsl.localhost\<distro>\...` inside the distro filesystem.
---@return string|nil path, string|nil err
local function to_windows_path(path)
  local wslpath = first_existing({ "/usr/bin/wslpath", "/bin/wslpath" })
  if not wslpath then return nil, "wslpath not found" end

  -- Blocking, but it is a local binary that returns in well under a
  -- millisecond, and this only ever runs on an explicit keypress.
  local result = vim.system({ wslpath, "-w", path }, { text = true }):wait()
  if result.code ~= 0 then
    return nil, ("wslpath failed: %s"):format(vim.trim(result.stderr or ""))
  end
  return vim.trim(result.stdout)
end

---@class Launcher
---@field argv string[]
---@field ignore_exit boolean|nil Set for launchers whose exit status is noise.

---@return Launcher|nil launcher, string|nil err
local function wsl_launcher(target, url)
  -- wslu's wslview takes Linux paths and honours the Windows default app. Not
  -- installed by default, hence everything below it.
  local wslview = first_existing({ "/usr/bin/wslview", "/usr/local/bin/wslview" })
  if wslview then return { argv = { wslview, target } } end

  if not url then
    local converted, err = to_windows_path(target)
    if not converted then return nil, err end
    target = converted
  end

  local explorer = "/mnt/c/Windows/explorer.exe"
  if exists(explorer) then
    -- explorer.exe exits 1 even when it successfully hands the file off, so its
    -- status carries no information.
    return { argv = { explorer, target }, ignore_exit = true }
  end

  local rundll32 = "/mnt/c/Windows/System32/rundll32.exe"
  if exists(rundll32) then
    return { argv = { rundll32, "url.dll,FileProtocolHandler", target } }
  end

  return nil, "no Windows launcher found (tried wslview, explorer.exe, rundll32.exe)"
end

---@return Launcher|nil launcher, string|nil err
local function launcher_for(target, url)
  if is_wsl() then return wsl_launcher(target, url) end

  -- has() on an OS name is a compile-time flag, not a provider probe, so it
  -- costs nothing -- unlike the executable() calls AGENTS.md rules out.
  if vim.fn.has("mac") == 1 then
    return { argv = { "/usr/bin/open", target } }
  end

  if vim.fn.has("win32") == 1 then
    -- start's first quoted argument is the window title, so it needs an empty
    -- placeholder or it eats the path.
    return { argv = { "cmd.exe", "/c", "start", "", target } }
  end

  local linux = first_existing({
    "/usr/bin/xdg-open",
    "/usr/local/bin/xdg-open",
    "/bin/xdg-open",
  })
  if linux then return { argv = { linux, target } } end

  local gio = first_existing({ "/usr/bin/gio", "/usr/local/bin/gio" })
  if gio then return { argv = { gio, "open", target } } end

  return nil, "no opener found (tried xdg-open, gio)"
end

--------------------------------------------------------------------------------
-- Entry point
--------------------------------------------------------------------------------

---Open `target` in whatever the OS considers its default application.
---@param target string A path or a URL.
function M.open(target)
  local url = is_url(target)
  local path = target

  if not url then
    local resolved, err = resolve(target)
    if not resolved then
      vim.notify("open-image: " .. err, vim.log.levels.ERROR)
      return
    end
    path = resolved
  end

  local launcher, err = launcher_for(path, url)
  if not launcher then
    vim.notify("open-image: " .. err, vim.log.levels.ERROR)
    return
  end

  -- Detached so the viewer outlives this Neovim session.
  vim.system(launcher.argv, { detach = true, text = true }, function(result)
    if launcher.ignore_exit or result.code == 0 then return end
    vim.schedule(function()
      vim.notify(
        ("open-image: %s exited %d%s"):format(
          vim.fs.basename(launcher.argv[1]),
          result.code,
          result.stderr ~= "" and ("\n" .. vim.trim(result.stderr)) or ""
        ),
        vim.log.levels.ERROR
      )
    end)
  end)

  vim.notify("open-image: " .. vim.fs.basename(path))
end

---Open the markdown image link, HTML `src`, or bare image path under the cursor.
function M.open_under_cursor()
  local target = target_under_cursor()
  if not target or target == "" then
    vim.notify("open-image: no image link under the cursor", vim.log.levels.WARN)
    return
  end
  M.open(target)
end

return M

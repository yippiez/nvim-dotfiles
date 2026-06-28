-- Disable built-ins
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_tutor = 1

-- Disable unused remote-plugin providers. Probing for these (e.g. has("python3"))
-- shells out at startup; disabling them up front skips that.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.opt.lazyredraw = true
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 50
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.foldmethod = "manual"
vim.opt.viewoptions = "folds,cursor"
vim.opt.autoread = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.synmaxcol = 200

-- Clipboard support
-- NOTE: do NOT probe with vim.fn.executable("win32yank.exe") here — on WSL that
-- scans the whole Windows PATH (75+ /mnt/c entries) over the 9p filesystem and
-- costs ~500ms at startup. win32yank is resolved lazily on first yank instead.
--
-- COPY via OSC52 (a terminal escape, zero process spawn) instead of shelling out
-- to win32yank.exe on every yank: with clipboard=unnamedplus, every y/d/c/x
-- writes the + register, and a win32yank spawn blocks ~200ms each time. OSC52 is
-- instant. PASTE still uses win32yank so pulling text from Windows apps works;
-- internal yank->put is served from Neovim's own cache and never spawns.
-- (Requires a terminal that honours OSC52 clipboard writes — Windows Terminal does.)
if vim.fn.has("wsl") == 1 then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "osc52-copy/win32yank-paste",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = { "win32yank.exe", "-o", "--lf" }, ["*"] = { "win32yank.exe", "-o", "--lf" } },
    cache_enabled = true,
  }
end
vim.opt.clipboard = "unnamedplus"

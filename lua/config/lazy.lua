-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Each plugin lives in its own file under lua/plugins/ and returns a spec.
require("lazy").setup({ { import = "plugins" } }, {
  install = { missing = true, colorscheme = { "vague" } },
  -- No background update checker: with notify=false its results were only
  -- visible inside :Lazy anyway, and it spawns a git process per plugin
  -- (expensive on WSL) at startup + hourly. `:Lazy check` runs it on demand.
  checker = { enabled = false },
  change_detection = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

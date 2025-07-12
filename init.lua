require("config.lazy")
require("config.keymaps")
require("config.win32yank")
require("config.lsp")

vim.cmd.colorscheme("tokyonight")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

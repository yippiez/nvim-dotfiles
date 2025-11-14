require("config.lazy")
require("config.keymaps")

-- Only load win32yank on Windows/WSL
if vim.fn.has('win32') == 1 or vim.fn.has('wsl') == 1 then
    require("config.win32yank")
else
    -- Use system clipboard on macOS and Linux
    vim.opt.clipboard = "unnamedplus"
end

require("config.lsp")

-- Global indentation settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4

-- Line number settings
vim.opt.number = true
vim.opt.relativenumber = true

-- Fold settings to save manual folds
vim.opt.foldmethod = "manual"
vim.opt.viewoptions = "folds,cursor"

-- Auto-save and restore folds
vim.api.nvim_create_autocmd({"BufWinLeave"}, {
    pattern = {"*.*"},
    desc = "save view (folds), when closing file",
    command = "mkview",
})

vim.api.nvim_create_autocmd({"BufWinEnter"}, {
    pattern = {"*.*"},
    desc = "load view (folds), when opening file",
    command = "silent! loadview"
})

-- Initialize theme system
require("config.themes").init()


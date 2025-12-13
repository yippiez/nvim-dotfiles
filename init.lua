-- Performance settings
vim.opt.lazyredraw = true
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 50

require("config.lazy")
require("config.keymaps")
require("config.autocmds")

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

-- Disable line wrapping by default
vim.opt.wrap = false

-- Fold settings to save manual folds
vim.opt.foldmethod = "manual"
vim.opt.viewoptions = "folds,cursor"

-- Auto-save and restore folds (only for actual files, limited patterns)
vim.api.nvim_create_autocmd({"BufWinLeave"}, {
    pattern = {"*.py", "*.js", "*.ts", "*.jsx", "*.tsx", "*.svelte", "*.lua", "*.md"},
    desc = "save view (folds), when closing file",
    callback = function()
        if vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
            vim.cmd("mkview")
        end
    end,
})

vim.api.nvim_create_autocmd({"BufWinEnter"}, {
    pattern = {"*.py", "*.js", "*.ts", "*.jsx", "*.tsx", "*.svelte", "*.lua", "*.md"},
    desc = "load view (folds), when opening file",
    callback = function()
        if vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
            vim.cmd("silent! loadview")
        end
    end,
})

-- Initialize theme 
vim.cmd.colorscheme("tokyonight")


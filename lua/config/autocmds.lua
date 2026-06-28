local api = vim.api
local is_large_file = require("util").is_large_file

-- Save/restore folds
local fold_filetypes = "*.py,*.js,*.ts,*.jsx,*.tsx,*.svelte,*.lua,*.md"
api.nvim_create_autocmd("BufWinLeave", {
  pattern = fold_filetypes,
  callback = function(args)
    if not is_large_file(args.buf) then
      vim.cmd("silent! mkview")
    end
  end,
})
api.nvim_create_autocmd("BufWinEnter", {
  pattern = fold_filetypes,
  callback = function(args)
    if not is_large_file(args.buf) then
      vim.cmd("silent! loadview")
    end
  end,
})

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})

-- Return to last position
api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= api.nvim_buf_line_count(0) then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Shared helpers used across config + plugin modules.
local M = {}

-- Large-file guard (used by treesitter, folds, etc.)
M.LARGE_FILE_SIZE = 100 * 1024 -- 100 KB

function M.is_large_file(bufnr)
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr or 0))
  return ok and stats and stats.size > M.LARGE_FILE_SIZE
end

return M

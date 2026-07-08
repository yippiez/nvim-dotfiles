-- Shared helpers used across config + plugin modules.
local M = {}

-- Large-file guard (used by treesitter, folds, cmp-buffer, etc.)
M.LARGE_FILE_SIZE = 100 * 1024 -- 100 KB: treesitter/folds off, LSP still on
M.HUGE_FILE_SIZE = 1024 * 1024 -- 1 MB: ft=bigfile, everything off (see config/bigfile.lua)

-- Cached per buffer: several consumers (treesitter disable, fold autocmds,
-- cmp-buffer gating) ask repeatedly, and each uncached call is an fs_stat
-- syscall — slow for files on the 9p /mnt/c mount. The verdict is "was the
-- file big when opened", so computing once per buffer is correct enough.
function M.is_large_file(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  local cached = vim.b[bufnr].large_file
  if cached ~= nil then
    return cached
  end
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
  local large = (ok and stats and stats.size > M.LARGE_FILE_SIZE) or false
  vim.b[bufnr].large_file = large
  return large
end

return M

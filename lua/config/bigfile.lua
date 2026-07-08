-- Huge-file guard (> util.HUGE_FILE_SIZE, 1 MB).
--
-- The 100 KB guard (util.is_large_file) only disables treesitter/folds — LSP,
-- syntax, gitsigns etc. still run. For genuinely huge files that isn't enough:
-- LSP didOpen ships the whole buffer to the server, regex syntax scales with
-- line count, and swapfile writes the buffer to disk.
--
-- Instead of gating each feature separately, detect huge files at filetype
-- level and assign ft="bigfile". LSP activation (vim.lsp.enable), treesitter,
-- and syntax are all keyed on the real filetype, so none of them ever start —
-- no attach-then-detach churn. Cheap: one getfsize (a single stat, no PATH
-- scan) during filetype detection.
local util = require("util")

vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, buf)
        if path and buf and vim.bo[buf].filetype ~= "bigfile"
            and vim.fn.getfsize(path) > util.HUGE_FILE_SIZE then
          return "bigfile"
        end
      end,
    },
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "bigfile",
  callback = function(args)
    vim.b[args.buf].large_file = true -- pre-seed util.is_large_file cache
    vim.bo[args.buf].swapfile = false
    vim.bo[args.buf].undofile = false
  end,
})

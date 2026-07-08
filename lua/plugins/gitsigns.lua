-- Git signs
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      -- Don't diff huge files: the built-in max_file_length gate counts lines,
      -- which misses huge few-line files (minified JS, logs).
      on_attach = function(bufnr)
        if vim.bo[bufnr].filetype == "bigfile" then
          return false
        end
      end,
      signs = {
        add = { text = "┃" }, change = { text = "┃" }, delete = { text = "_" },
        topdelete = { text = "‾" }, changedelete = { text = "~" }, untracked = { text = "┆" },
      },
    })
  end,
}

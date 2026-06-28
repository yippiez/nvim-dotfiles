local is_large_file = require("util").is_large_file

-- Treesitter
return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Pre-install parsers for languages actually used here so opening one of
      -- these files never pays the ~475ms compile-on-first-open that
      -- auto_install incurs for a missing parser. auto_install still covers
      -- anything not listed.
      ensure_installed = {
        "lua", "vim", "vimdoc", "python", "javascript", "typescript", "tsx",
        "dart", "latex", "rust", "go", "gomod", "elixir", "haskell",
        "json", "yaml", "toml", "html", "css", "bash", "markdown", "markdown_inline",
      },
      auto_install = true,
      highlight = {
        enable = true,
        disable = function(_, bufnr)
          if is_large_file(bufnr) then
            -- Fall back to regex syntax for large files
            vim.bo[bufnr].syntax = vim.bo[bufnr].filetype
            return true
          end
        end,
      },
      indent = {
        enable = true,
        disable = function(_, bufnr)
          return is_large_file(bufnr)
        end,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = false,
          node_decremental = "grm",
        },
      },
    })
  end,
}

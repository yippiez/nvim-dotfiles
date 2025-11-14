-- https://github.com/vague-theme/vague.nvim
return {
  "vague-theme/vague.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("vague").setup({
      transparent = false,
      bold = true,
      italic = true,
      style = {
        boolean = "bold",
        number = "none",
        float = "none",
        error = "bold",
        comments = "italic",
        conditionals = "none",
        functions = "none",
        headings = "bold",
        operators = "none",
        strings = "italic",
        variables = "none",
        keywords = "none",
        keyword_return = "italic",
        keywords_loop = "none",
        keywords_label = "none",
        keywords_exception = "none",
        builtin_constants = "bold",
        builtin_functions = "none",
        builtin_types = "bold",
        builtin_variables = "none",
      },
      plugins = {
        cmp = {
          match = "bold",
          match_fuzzy = "bold",
        },
        dashboard = {
          footer = "italic",
        },
        lsp = {
          diagnostic_error = "bold",
          diagnostic_hint = "none",
          diagnostic_info = "italic",
          diagnostic_ok = "none",
          diagnostic_warn = "bold",
        },
        neotest = {
          focused = "bold",
          adapter_name = "bold",
        },
        telescope = {
          match = "bold",
        },
      },
    })
  end,
}

-- Todo comments
return {
  "folke/todo-comments.nvim",
  event = "BufReadPost",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("todo-comments").setup({
      signs = false,
      keywords = {
        FIX = { icon = "F", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = "T", color = "info" },
        HACK = { icon = "H", color = "warning" },
        WARN = { icon = "W", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = "P", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = "N", color = "hint", alt = { "INFO" } },
        TEST = { icon = "T", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        FACT = { icon = "F", color = "error" },
      },
    })
  end,
}

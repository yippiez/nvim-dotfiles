-- https://github.com/folke/todo-comments.nvim
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    keywords = {
      FIX = { icon = "F", color = "error" },
      TODO = { icon = "T", color = "info" },
      HACK = { icon = "H", color = "warning" },
      WARN = { icon = "W", color = "warning" },
      PERF = { icon = "P", color = "default" },
      NOTE = { icon = "N", color = "hint" },
      TEST = { icon = "T", color = "test" },
    }
  }
}
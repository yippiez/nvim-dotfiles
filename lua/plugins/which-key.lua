-- Which-key
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    require("which-key").setup({
      preset = "modern",
      win = {
        title = false,
        border = "rounded",
        width = 0.99,
        col = 0,
      },
      icons = { mappings = false },
    })
  end,
}

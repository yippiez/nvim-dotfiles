-- Colorscheme: Vague (default)
return {
  "vague-theme/vague.nvim",
  priority = 1000,
  config = function()
    require("vague").setup({
      style = { boolean = "none", comments = "none", strings = "none" },
    })
    vim.cmd.colorscheme("vague")
  end,
}

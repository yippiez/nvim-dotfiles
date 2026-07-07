local map = vim.keymap.set

-- TreeSJ (split/join)
return {
  "Wansmer/treesj",
  keys = {
    { "<leader>ls", desc = "Toggle split/join" },
    { "<leader>lS", desc = "Toggle recursive split/join" },
  },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    local tsj = require("treesj")
    tsj.setup({ use_default_keymaps = false })
    map("n", "<leader>ls", tsj.toggle, { desc = "Toggle split/join" })
    map("n", "<leader>lS", function() tsj.toggle({ split = { recursive = true } }) end, { desc = "Toggle recursive" })
  end,
}

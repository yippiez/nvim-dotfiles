local map = vim.keymap.set

-- Flash
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  config = function()
    local flash = require("flash")
    flash.setup({})
    map({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash" })
    map({ "n", "x", "o" }, "S", flash.treesitter, { desc = "Flash Treesitter" })
    map("o", "r", flash.remote, { desc = "Remote Flash" })
    map({ "o", "x" }, "R", flash.treesitter_search, { desc = "Treesitter Search" })
    map("c", "<C-s>", flash.toggle, { desc = "Toggle Flash Search" })
  end,
}

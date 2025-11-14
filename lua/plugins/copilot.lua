-- https://github.com/zbirenbaum/copilot.lua
return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<Right>",
          accept_word = false,
          accept_line = false,
          next = "<S-Down>",
          prev = "<S-Up>",
        },
      },
      panel = { enabled = false },
    })
  end,
}
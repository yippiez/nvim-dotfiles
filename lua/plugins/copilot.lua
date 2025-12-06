-- https://github.com/zbirenbaum/copilot.lua
-- NOTE: Accept key is Cmd+Right on macOS, Ctrl+Right on Windows/Linux
local is_mac = vim.fn.has("macunix") == 1
local accept_key = is_mac and "<D-Right>" or "<C-Right>"

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
                    accept = accept_key,
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
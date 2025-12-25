-- https://github.com/Vigemus/iron.nvim
return {
    'Vigemus/iron.nvim',
    keys = {
        { "<leader>rr", desc = "Toggle REPL (right split)" },
        { "<leader>rR", desc = "Toggle REPL (wide right split)" },
        { "<leader>rF", desc = "Force restart REPL" },
        { "<leader>rl", mode = { "n", "v" }, desc = "Send line/selection to REPL" },
        { "<leader>rb", desc = "Send code block to REPL" },
        { "<leader>ri", desc = "Interrupt REPL" },
        { "<leader>rf", desc = "Focus REPL" },
        { "<leader>rh", desc = "Hide REPL" },
    },
    config = function()
        local iron = require("iron.core")
        local view = require("iron.view")
        local common = require("iron.fts.common")

        iron.setup {
            config = {
                scratch_repl = true,
                repl_definition = {
                    sh = {
                        command = {"zsh"}
                    },
                    python = {
                        command = { "python3" },
                        format = common.bracketed_paste_python,
                        block_dividers = { "# %%", "#%%" },
                    }
                },
                repl_filetype = function(bufnr, ft)
                    return ft
                end,
                repl_open_cmd = {
                    view.split.vertical.rightbelow("50%"), -- Right 50% split (rr)
                    view.split.vertical.rightbelow("100%"), -- Full "100%" split (rR) 
                },
            },
            keymaps = {
                toggle_repl_with_cmd_1 = "<leader>rr", -- Right split
                toggle_repl_with_cmd_2 = "<leader>rR", -- Wide right split
                restart_repl = "<leader>rF",
                send_line = "<leader>rl",
                visual_send = "<leader>rl",
                send_code_block = "<leader>rb", -- Send block to REPL
                interrupt = "<leader>ri",
            },
            highlight = {
                italic = true
            },
            ignore_blank_lines = true,
        }

        -- Add descriptions for which-key
        local wk = require("which-key")
        wk.add({
            { "<leader>rr", desc = "Toggle REPL (right split)" },
            { "<leader>rR", desc = "Toggle REPL (wide right split)" },
            { "<leader>rF", desc = "Force restart REPL" },
            { "<leader>rl", desc = "Send line to REPL" },
            { "<leader>rl", desc = "Send selection to REPL", mode = "v" },
            { "<leader>rb", desc = "Send code block to REPL" },
            { "<leader>ri", desc = "Interrupt REPL" },
        })

        -- Additional REPL keymaps
        vim.keymap.set('n', '<leader>rf', '<cmd>IronFocus<cr>', { desc = 'Focus REPL' })
        vim.keymap.set('n', '<leader>rh', '<cmd>IronHide<cr>', { desc = 'Hide REPL' })
        
        -- Easy escape from terminal
        vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
    end,
}

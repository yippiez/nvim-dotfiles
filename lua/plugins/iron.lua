-- Sourc https://github.com/Vigemus/iron.nvim

return {
  'Vigemus/iron.nvim',
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
          view.bottom("50%") -- Bottom 50% split (rb)
        },
      },
      keymaps = {
        toggle_repl_with_cmd_1 = "<space>rr", -- Right split
        toggle_repl_with_cmd_2 = "<space>rb", -- Bottom split
        restart_repl = "<space>rR",
        send_line = "<space>rl",
        visual_send = "<space>rv",
        interrupt = "<space>ri",
      },
      highlight = {
        italic = true
      },
      ignore_blank_lines = true,
    }

    -- Add descriptions for which-key
    local wk = require("which-key")
    wk.add({
      { "<space>rr", desc = "Toggle REPL (right split)" },
      { "<space>rb", desc = "Toggle REPL (bottom split)" },
      { "<space>rR", desc = "Restart REPL" },
      { "<space>rl", desc = "Send line to REPL" },
      { "<space>rv", desc = "Send selection to REPL", mode = "v" },
      { "<space>ri", desc = "Interrupt REPL" },
    })

    -- Additional REPL keymaps
    vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>', { desc = 'Focus REPL' })
    vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>', { desc = 'Hide REPL' })
    
    -- Easy escape from terminal
    vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
  end,
}

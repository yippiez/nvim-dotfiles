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
        repl_open_cmd = view.bottom(40),
      },
      keymaps = {
        toggle_repl = "<space>rr",
        restart_repl = "<space>rR",
        send_line = "<space>sl",
        visual_send = "<space>sv",
        interrupt = "<space>ri",
      },
      highlight = {
        italic = true
      },
      ignore_blank_lines = true,
    }

    vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
    vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')
  end,
}
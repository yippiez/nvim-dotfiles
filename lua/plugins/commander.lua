return {
  "FeiyouG/commander.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("commander").setup({
      components = {
        "DESC",
        "KEYS",
        "CMD",
        "CAT",
      },
      sort_by = {
        "DESC",
        "KEYS",
        "CMD",
        "CAT",
      },
      separator = " ",
      auto_replace_desc_with_cmd = true,
      prompt_title = "Commander",
      integration = {
        telescope = {
          enable = true,
          theme = require("telescope.themes").get_ivy
        },
        lazy = {
          enable = true,
          set_plugin_name_as_cat = false
        }
      }
    })

    -- Add commands
    require("commander").add({
      {
        desc = "Find files",
        cmd = "<CMD>Telescope find_files<CR>",
        keys = { "n", "<leader>ff" },
      },
      {
        desc = "Live grep", 
        cmd = "<CMD>Telescope live_grep<CR>",
        keys = { "n", "<leader>fg" },
      },
      {
        desc = "Buffers",
        cmd = "<CMD>Telescope buffers<CR>",
        keys = { "n", "<leader>fb" },
      },
      {
        desc = "Terminal",
        cmd = function()
          -- Create floating terminal in center of screen
          local width = math.floor(vim.o.columns * 0.8)
          local height = math.floor(vim.o.lines * 0.8)
          local row = math.floor((vim.o.lines - height) / 2)
          local col = math.floor((vim.o.columns - width) / 2)
          
          -- Create new buffer
          local buf = vim.api.nvim_create_buf(false, true)
          
          -- Window options
          local opts = {
            relative = 'editor',
            width = width,
            height = height,
            row = row,
            col = col,
            style = 'minimal',
            border = 'rounded',
          }
          
          -- Create floating window
          local win = vim.api.nvim_open_win(buf, true, opts)
          
          -- Start terminal
          vim.fn.termopen(vim.o.shell, {
            on_exit = function()
              -- Close window when terminal exits
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
              end
            end
          })
          
          -- Enter insert mode
          vim.cmd('startinsert')
        end,
        keys = { "n", "<leader>t" },
      },
    })
    
    -- VS Code-style command palette function
    local function vscode_command_palette()
      local builtin = require('telescope.builtin')
      
      -- Start with file search
      builtin.find_files({
        prompt_title = "Find Files (type > for commands)",
        attach_mappings = function(_, map)
          -- When user types '>', switch to command mode
          map('i', '>', function()
            vim.cmd('stopinsert')
            vim.schedule(function()
              require("commander").show()
            end)
          end)
          return true
        end,
      })
    end
    
    -- Set keybinding for VS Code-style command palette
    vim.keymap.set("n", "<C-p>", vscode_command_palette, { desc = "Command Palette" })
  end,
}
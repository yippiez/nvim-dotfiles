return {
  "FeiyouG/commander.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("commander").setup({
      components = {
        "DESC",
        "KEYS",
      },
      sort_by = {
        "DESC",
      },
      separator = " ",
      auto_replace_desc_with_cmd = false,
      prompt_title = "Commander",
      integration = {
        telescope = {
          enable = true,
          theme = function()
            return {
              layout_strategy = 'horizontal',
              layout_config = {
                width = function(_, max_columns, _)
                  return math.min(max_columns, 80)
                end,
                height = 0.4,
                prompt_position = 'top',
                anchor = 'N',
                preview_cutoff = 0,
                horizontal = {
                  preview_width = 0,
                },
              },
              previewer = false,
              sorting_strategy = 'ascending',
            }
          end
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
        desc = "Find Files Search through project files",
        cmd = "<CMD>Telescope find_files<CR>",
        keys = { "n", "<leader>ff" },
      },
      {
        desc = "Terminal Launch floating terminal",
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
          
          -- Add escape key mapping to close terminal
          vim.api.nvim_buf_set_keymap(buf, 't', '<Esc>', '<C-\\><C-n>:q<CR>', { noremap = true, silent = true })
          
          -- Enter insert mode (schedule to ensure terminal is ready)
          vim.schedule(function()
            vim.cmd('startinsert')
          end)
        end,
        keys = { "n", "<leader>t" },
      },
      {
        desc = "Go to Next Error Navigate to next diagnostic",
        cmd = function() vim.diagnostic.goto_next() end,
        keys = { "n", "]d" },
      },
      {
        desc = "Go to Previous Error Navigate to previous diagnostic",
        cmd = function() vim.diagnostic.goto_prev() end,
        keys = { "n", "[d" },
      },
      {
        desc = "Oil File manager for directories",
        cmd = "<CMD>Oil<CR>",
        keys = { "n", "<leader>o" },
      },
      {
        desc = "Live Grep Search text in files", 
        cmd = "<CMD>Telescope live_grep<CR>",
        keys = { "n", "<leader>fg" },
      },
      {
        desc = "Buffers Switch between open files",
        cmd = "<CMD>Telescope buffers<CR>",
        keys = { "n", "<leader>fb" },
      },
      {
        desc = "Tree Show project structure",
        cmd = function()
          -- Create floating window for tree output
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
            title = 'Project Tree',
            title_pos = 'center',
          }
          
          -- Create floating window
          local win = vim.api.nvim_open_win(buf, true, opts)
          
          -- Check if exa is available, fallback to tree command
          local cmd_string
          if vim.fn.executable('exa') == 1 then
            cmd_string = 'exa --tree --level 5 --color=always --ignore-glob ".git|__pycache__|*.pyc|node_modules|.venv|.env|*.egg-info|.pytest_cache|.coverage|htmlcov|.DS_Store|Thumbs.db|.idea|.vscode"'
          else
            cmd_string = 'tree -L 5 -C -I ".git|__pycache__|*.pyc|node_modules|.venv|.env|*.egg-info|.pytest_cache|.coverage|htmlcov|.DS_Store|Thumbs.db|.idea|.vscode"'
          end
          
          -- Use terminal to run command with colors
          vim.fn.termopen(cmd_string, {
            on_exit = function()
              -- Set buffer options for read-only display
              vim.api.nvim_buf_set_option(buf, 'modifiable', false)
              vim.api.nvim_buf_set_option(buf, 'readonly', true)
              
              -- Add keybinding to close with escape or q
              vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':q<CR>', { noremap = true, silent = true })
              vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
              vim.api.nvim_buf_set_keymap(buf, 't', '<Esc>', '<C-\\><C-n>:q<CR>', { noremap = true, silent = true })
            end
          })
        end,
        keys = { "n", "<leader>T" },
      },
      {
        desc = "Git Preview Hunk Inline Show current hunk changes inline",
        cmd = "<CMD>Gitsigns preview_hunk_inline<CR>",
      },
      {
        desc = "Git Preview Hunk Popup Show current hunk changes in popup",
        cmd = "<CMD>Gitsigns preview_hunk<CR>",
      },
      {
        desc = "Git Toggle Line Blame Show blame for current line",
        cmd = "<CMD>Gitsigns toggle_current_line_blame<CR>",
      },
    })
    
    -- Set keybinding to directly launch commander
    vim.keymap.set("n", "<C-p>", function()
      require("commander").show()
    end, { desc = "Command Palette" })
  end,
}
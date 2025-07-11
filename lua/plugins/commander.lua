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
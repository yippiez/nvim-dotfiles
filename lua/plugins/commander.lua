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
          enable = false,
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
      {
        desc = "Enable Line Wrap",
        cmd = "<CMD>set wrap<CR>",
      },
      {
        desc = "Disable Line Wrap", 
        cmd = "<CMD>set nowrap<CR>",
      },
      {
        desc = "New Tab",
        cmd = "<CMD>tabnew<CR>",
      },
      {
        desc = "New Buffer",
        cmd = "<CMD>enew<CR>",
      },
    })
    
    -- Set keybinding to directly launch commander
    vim.keymap.set("n", "<C-p>", function()
      require("commander").show()
    end, { desc = "Command Palette" })
  end,
}
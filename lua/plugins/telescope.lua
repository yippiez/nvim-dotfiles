local map = vim.keymap.set

-- Telescope
return {
  "nvim-telescope/telescope.nvim",
  -- Preload just after startup (invisible to the user) so the FIRST <leader>ff
  -- is as instant as later ones — no lazy-load chain stall on the keypress.
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    -- Compiled C sorter: ranks/filters large result sets far faster than the
    -- default Lua sorter (this is what made the first list slow to populate).
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        file_ignore_patterns = { "node_modules", "%.git/" },
        layout_strategy = "bottom_pane",
        layout_config = { bottom_pane = { height = 0.4, prompt_position = "bottom" } },
        previewer = false,
      },
      pickers = { find_files = { disable_devicons = true }, buffers = { disable_devicons = true } },
      extensions = {
        fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
      },
    })
    pcall(telescope.load_extension, "fzf")
    local builtin = require("telescope.builtin")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local function open_in_existing_buf(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      if entry then
        local filepath = entry.path or entry[1]
        -- Check if buffer already exists for this file
        for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
          if vim.fn.fnamemodify(b.name, ":p") == vim.fn.fnamemodify(filepath, ":p") then
            vim.api.nvim_set_current_buf(b.bufnr)
            return
          end
        end
        vim.cmd("edit " .. vim.fn.fnameescape(filepath))
      end
    end

    local custom_find_files = function()
      builtin.find_files({
        find_command = { "fd", "--type", "f", "--color", "never", "--hidden", "--ignore-file", ".jjignore" },
        attach_mappings = function(_, map)
          map("i", "<CR>", open_in_existing_buf)
          map("n", "<CR>", open_in_existing_buf)
          return true
        end,
      })
    end
    local custom_live_grep = function()
      builtin.live_grep({
        additional_args = { "--hidden", "--ignore-file", ".jjignore" },
      })
    end
    map("n", "<leader>ff", custom_find_files, { desc = "Find files" })
    map("n", "<leader>fg", custom_live_grep, { desc = "Live grep" })
    map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
    map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
    map("n", "<leader>fc", builtin.commands, { desc = "Commands" })
    map("n", "<leader>fS", builtin.git_status, { desc = "Git status" })
    map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
    map("n", "<leader>fB", builtin.git_bcommits, { desc = "Buffer commits" })
  end,
}

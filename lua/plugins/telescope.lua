-- https://github.com/nvim-telescope/telescope.nvim
return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Telescope find files" },
        { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Telescope live grep" },
        { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Telescope buffers" },
        { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Telescope help tags" },
        { "<leader>fc", function() require("telescope.builtin").commands() end, desc = "Telescope commands" },
        { "<leader>fS", function() require("telescope.builtin").git_status() end, desc = "Telescope git status" },
        { "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Telescope document symbols" },
        { "<leader>fG", function() require("telescope.builtin").git_commits() end, desc = "Telescope git commits" },
        { "<leader>fB", function() require("telescope.builtin").git_bcommits() end, desc = "Telescope buffer commits" },
    },
    cmd = "Telescope",
    config = function()
        require('telescope').setup({
            defaults = {
                layout_strategy = 'bottom_pane',
                layout_config = {
                    height = 0.4,
                    width = function(_, max_columns, _)
                        return math.min(max_columns, 80)
                    end,
                    prompt_position = 'top',
                },
                previewer = false,
                file_ignore_patterns = { "node_modules" },
                sorting_strategy = 'ascending',
                prompt_prefix = '> ',
                selection_caret = '  ',
                entry_prefix = '  ',
                results_title = false,
                prompt_title = false,
                preview_title = false,
            },
            pickers = {
                find_files = {
                    disable_devicons = true,
                },
                live_grep = {
                    disable_devicons = true,
                },
                grep_string = {
                    disable_devicons = true,
                },
                buffers = {
                    disable_devicons = true,
                },
                git_status = {
                    prompt_title = "Git Status (staged | unstaged)",
                    git_icons = {
                        added = "+",
                        changed = "~",
                        copied = "+",
                        deleted = "-",
                        renamed = "→",
                        unmerged = "!",
                        untracked = "?",
                    },
                },
            },
        })
    end,
}

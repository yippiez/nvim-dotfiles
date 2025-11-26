-- https://github.com/nvim-telescope/telescope.nvim
return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = "VeryLazy",
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
            },
        })
    end,
}


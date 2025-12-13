-- https://github.com/dmtrKovalenko/fff.nvim
return {
    'dmtrKovalenko/fff.nvim',
    build = function()
        require("fff.download").download_or_build_binary()
    end,
    lazy = false,
    opts = {
        prompt = '> ',
        title = 'Files',
        layout = {
            height = 0.6,
            width = 0.9,
            prompt_position = 'top',
            preview_position = 'right',
            preview_size = 0.5,
        },
        preview = {
            enabled = true,
            max_size = 10 * 1024 * 1024,
            line_numbers = true,
            wrap_lines = false,
            show_file_info = true,
        },
        debug = {
            enabled = false,
            show_scores = false,
        },
    },
    keys = {
        {
            "<leader>ff",
            function() require('fff').find_in_git_root() end,
            desc = 'Find files',
        },
    },
}

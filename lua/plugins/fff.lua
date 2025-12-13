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
            height = 0.4,
            width = 0.5,
            prompt_position = 'top',
            preview_position = 'right',
            preview_size = 0.5,
        },
        preview = {
            enabled = false,
        },
        debug = {
            enabled = false,
            show_scores = false,
        },
    },
    keys = {
        {
            "<leader>ff",
            function() require('fff').find_files() end,
            desc = 'Find files',
        },
    },
}

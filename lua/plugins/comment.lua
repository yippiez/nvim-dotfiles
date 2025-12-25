-- https://github.com/numToStr/Comment.nvim
return {
        'numToStr/Comment.nvim',
        event = { "BufReadPost", "BufNewFile" },
        opts = {
                -- Disable all default keybindings
                mappings = {
                        basic = false,
                        extra = false,
                },
        }
}

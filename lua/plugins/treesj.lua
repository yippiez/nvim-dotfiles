-- https://github.com/Wansmer/treesj
return {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = {
        { '<leader>ls', '<cmd>TSJToggle<cr>', desc = 'Toggle split/join code block' },
        { '<leader>lS', function()
            require('treesj').toggle({ split = { recursive = true } })
        end, desc = 'Toggle split/join recursively' },
    },
    config = function()
        require('treesj').setup({
            use_default_keymaps = false,
        })
    end,
}
-- https://github.com/hrsh7th/nvim-cmp
return {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
    },
    config = function()
        local cmp = require('cmp')

        cmp.setup({
            mapping = cmp.mapping.preset.insert({
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<M-.>'] = cmp.mapping.complete(),
                ['<CR>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        if cmp.get_selected_entry() then
                            local entry = cmp.get_selected_entry()
                            cmp.confirm({ select = false })
                        else
                            -- Nothing selected: abort and newline
                            cmp.abort()
                            fallback()
                        end
                    else
                        fallback()
                    end
                end),
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
            }, {
                { name = 'buffer' },
                { name = 'path' },
            }),
        })
    end,
}

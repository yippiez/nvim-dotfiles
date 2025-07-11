return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('telescope').setup({
      defaults = {
        layout_strategy = 'center',
        layout_config = {
          width = 0.6,
          height = 0.8,
          prompt_position = 'top',
        },
        previewer = false,
      },
    })
  end,
}


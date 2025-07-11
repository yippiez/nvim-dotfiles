return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('telescope').setup({
      defaults = {
        layout_strategy = 'horizontal',
        layout_config = {
          width = 0.95,
          height = 0.8,
          prompt_position = 'top',
          preview_width = 0.5,
          preview_cutoff = 50,
        },
        previewer = true,
      },
    })
  end,
}


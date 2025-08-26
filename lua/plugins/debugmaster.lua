-- https://github.com/miroshQa/debugmaster.nvim
return {
  'miroshQa/debugmaster.nvim',
  dependencies = {
    'mfussenegger/nvim-dap',
  },
  config = function()
    local dm = require('debugmaster')
    vim.keymap.set({ 'n', 'v' }, '<leader>d', dm.mode.toggle, { nowait = true })
    
    -- Optional: Enable Lua debugging integration
    -- dm.plugins.osv_integration.enabled = true
    
    -- Optional: Disable cursor highlighting in debug mode
    -- dm.plugins.cursor_hl.enabled = false
    
    -- Optional: Disable auto UI toggle
    -- dm.plugins.ui_auto_toggle.enabled = false
  end,
}
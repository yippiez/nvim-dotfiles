return {
  'nvimtools/hydra.nvim',
  config = function()
    local Hydra = require('hydra')

    Hydra({
      name = "Toggle Debug Mode",
      body = "<leader>d",
      config = {
        color = 'pink',
        invoke_on_body = true,
        hint = false,
        on_enter = function()
          vim.api.nvim_exec_autocmds("User", { pattern = "HydraEnter", data = { name = "Toggle Debug Mode" } })
        end,
        on_exit = function()
          vim.api.nvim_exec_autocmds("User", { pattern = "HydraLeave", data = { name = "Toggle Debug Mode" } })
        end,
      },
      mode = 'n',
      heads = {
        { 't', function() require('dap').toggle_breakpoint() end, { desc = 'Toggle Breakpoint' } },
        { 'c', function() require('dap').continue() end, { desc = 'Continue/Start' } },
        { 'R', function() require('dap').restart() end, { desc = 'Restart' } },
        { 'T', function() require('dap').terminate() end, { desc = 'Terminate' } },
        { 'o', function() require('dap').step_over() end, { desc = 'Step Over' } },
        { 'm', function() require('dap').step_into() end, { desc = 'Step Into' } },
        { 'q', function() require('dap').step_out() end, { desc = 'Step Out' } },
        { 'r', function() require('dap').run_to_cursor() end, { desc = 'Run to Cursor' } },
        { 'u', function() require('dap').repl.toggle() end, { desc = 'Toggle REPL' } },
        { '<leader>d', nil, { exit = true, desc = 'Toggle Debug Mode Off' } },
        { 'Q', nil, { exit = true, desc = 'Quit Debug Mode' } },
        { '<Esc>', nil, { exit = true, desc = 'Exit' } },
      }
    })
  end
}
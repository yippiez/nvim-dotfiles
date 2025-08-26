-- https://github.com/mfussenegger/nvim-dap
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'nvim-neotest/nvim-nio',
  },
  config = function()
    local dap = require('dap')
    
    -- Python debugger configuration with uv
    dap.adapters.python = function(cb, config)
      if config.request == 'attach' then
        local port = (config.connect or config).port
        local host = (config.connect or config).host or '127.0.0.1'
        cb({
          type = 'server',
          port = assert(port, '`connect.port` is required for a python `attach` configuration'),
          host = host,
          options = {
            source_filetype = 'python',
          },
        })
      else
        cb({
          type = 'executable',
          command = 'uv',
          args = { 'run', 'python', '-m', 'debugpy.adapter' },
          options = {
            source_filetype = 'python',
          },
        })
      end
    end

    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file with uv',
        program = '${file}',
        console = 'integratedTerminal',
        justMyCode = false,
        stopOnEntry = false,
        pythonPath = function()
          -- Get the python path from uv in current directory
          local cwd = vim.fn.getcwd()
          local handle = io.popen('cd "' .. cwd .. '" && uv run which python 2>/dev/null')
          if handle then
            local result = handle:read("*a")
            handle:close()
            if result and result ~= "" then
              return result:gsub("%s+", "") -- trim whitespace
            end
          end
          -- Fallback to system python
          return 'python3'
        end,
        cwd = '${workspaceFolder}',
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file (system python)',
        program = '${file}',
        console = 'integratedTerminal',
        justMyCode = false,
        stopOnEntry = false,
        pythonPath = 'python3',
        cwd = '${workspaceFolder}',
      },
    }

    -- Debug keymaps handled by hydra debug mode
    -- Use <leader>d to enter debug mode, then single keys for debugging
  end,
}
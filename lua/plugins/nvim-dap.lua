-- https://github.com/mfussenegger/nvim-dap
return {
    'mfussenegger/nvim-dap',
    event = "VeryLazy",
    dependencies = {
        'nvim-neotest/nvim-nio',
    },
    config = function()
        local dap = require('dap')

        -- High-contrast DAP signs and highlights
        vim.fn.sign_define('DapBreakpoint', { text = '⦿', texthl = 'DapBreakpoint', linehl = '', numhl = 'DapBreakpoint' })
        vim.fn.sign_define('DapBreakpointCondition', { text = '◈', texthl = 'DapBreakpointCondition', linehl = '', numhl = 'DapBreakpointCondition' })
        vim.fn.sign_define('DapBreakpointRejected', { text = '⊗', texthl = 'DapBreakpointRejected', linehl = '', numhl = 'DapBreakpointRejected' })
        vim.fn.sign_define('DapStopped', { text = '➤', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = 'DapStopped' })

        vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#ff5555', bold = true })
        vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#ffbd2e', bold = true })
        vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#ff9e64', bold = true })
        vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#00d3a7', bold = true })
        vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#20403a' })

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

        -- Override DAP continue to show helpful error messages
        local original_continue = dap.continue
        dap.continue = function()
            local filetype = vim.bo.filetype
            
            -- Check if configuration exists for current filetype
            if not dap.configurations[filetype] or #dap.configurations[filetype] == 0 then
                vim.notify("Debugging not supported for filetype: " .. filetype, vim.log.levels.ERROR)
                return
            end
            
            original_continue()
        end
        
        -- Debug keymaps handled by hydra debug mode
        -- Use <leader>d to enter debug mode, then single keys for debugging
    end,
}

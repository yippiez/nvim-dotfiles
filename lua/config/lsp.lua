-- Configure diagnostics display
vim.diagnostic.config({
  virtual_text = {
    source = "always",
    prefix = "●",
    spacing = 2,
    format = function(diagnostic)
      local max_width = 50
      local message = diagnostic.message
      if #message > max_width then
        return message:sub(1, max_width - 3) .. "..."
      end
      return message
    end,
  },
  float = {
    source = "always",
    wrap = true,
    border = "rounded",
    header = "",
    prefix = "",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Show diagnostic popup on hover
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = 'rounded',
      source = 'always',
      prefix = ' ',
      scope = 'cursor',
    }
    vim.diagnostic.open_float(nil, opts)
  end
})


-- Python LSP configuration
vim.lsp.enable('pyright')
vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
      },
      pythonPath = vim.fn.exepath('python'),
    },
  },
  on_new_config = function(config, root_dir)
    local function find_python_path(dir)
      -- Check for uv virtual environment
      local uv_venv = dir .. '/.venv/bin/python'
      if vim.fn.executable(uv_venv) == 1 then
        return uv_venv
      end
      
      -- Check for traditional venv
      local venv_python = dir .. '/venv/bin/python'
      if vim.fn.executable(venv_python) == 1 then
        return venv_python
      end
      
      -- Check VIRTUAL_ENV environment variable
      local venv_path = vim.fn.getenv('VIRTUAL_ENV')
      if venv_path and venv_path ~= vim.NIL then
        return venv_path .. '/bin/python'
      end
      
      return nil
    end
    
    local python_path = find_python_path(root_dir)
    if python_path then
      config.settings.python.pythonPath = python_path
    end
  end,
})
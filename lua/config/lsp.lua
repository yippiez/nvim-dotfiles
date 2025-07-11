-- Configure diagnostics display
vim.diagnostic.config({
  virtual_text = {
    source = "always",
    prefix = "●",
  },
  float = {
    source = "always",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
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
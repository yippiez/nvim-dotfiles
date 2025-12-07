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

-- Show diagnostic popup on hover with delay and only for relevant filetypes
vim.api.nvim_create_autocmd("CursorHold", {
    pattern = { "*.py", "*.js", "*.ts", "*.jsx", "*.tsx", "*.svelte", "*.go" },
    callback = function()
        vim.defer_fn(function()
            local opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = 'rounded',
                source = 'always',
                prefix = ' ',
                scope = 'cursor',
            }
            vim.diagnostic.open_float(nil, opts)
        end, 1000) -- 1 second delay
    end
})

-- Python LSP configuration
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
        },
    },
})

-- TypeScript/JavaScript LSP configuration
vim.lsp.config('ts_ls', {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
    settings = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = 'literal',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
        },
        javascript = {
            inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
        },
    },
})

-- Rust LSP configuration
vim.lsp.config('rust_analyzer', {
    cmd = { vim.fn.expand('~/.local/bin/rust-analyzer') },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
    settings = {
        ['rust-analyzer'] = {
            cargo = {
                loadOutDirsFromCheck = true,
            },
            procMacro = {
                enable = true,
            },
        },
    },
})

-- Svelte LSP configuration
vim.lsp.config('svelte', {
    cmd = { 'svelteserver', '--stdio' },
    filetypes = { 'svelte' },
    root_markers = { 'package.json', 'svelte.config.js', 'svelte.config.mjs', 'svelte.config.cjs', '.git' },
    settings = {
        svelte = {
            plugin = {
                html = { completions = { enable = true, emmet = false } },
                svelte = { completions = { enable = true, emmet = true } },
                css = { completions = { enable = true, emmet = true } },
            },
        },
    },
})

-- Go LSP configuration
vim.lsp.config('gopls', {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
                shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
        },
    },
})

-- Enable all LSP servers (they auto-attach based on filetypes)
vim.lsp.enable('pyright')
vim.lsp.enable('ts_ls')
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('svelte')
vim.lsp.enable('gopls')

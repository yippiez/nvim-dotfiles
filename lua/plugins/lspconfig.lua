-- LSP core
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = function()
    -- LSP capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if cmp_ok then
      capabilities = cmp_lsp.default_capabilities(capabilities)
    end
    vim.lsp.config("*", { capabilities = capabilities })

    -- Pyright
    vim.lsp.config("pyright", {
      cmd = { vim.fn.expand("~/.local/bin/pyright-langserver"), "--stdio" },
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "openFilesOnly",
          },
        },
      },
    })

    -- TypeScript/JavaScript
    vim.lsp.config("ts_ls", {
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayFunctionParameterTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayFunctionParameterTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
      },
    })

    -- Rust Analyzer
    vim.lsp.config("rust_analyzer", {
      cmd = { vim.fn.expand("~/.local/bin/rust-analyzer") },
      settings = {
        ["rust-analyzer"] = {
          cargo = { loadOutDirsFromCheck = true },
          procMacro = { enable = true },
        },
      },
    })

    -- Go
    vim.lsp.config("gopls", {
      cmd = { vim.fn.expand("~/go/bin/gopls") },
      settings = {
        gopls = {
          analyses = { unusedparams = true, shadow = true },
          staticcheck = true,
          gofumpt = true,
        },
      },
    })

    -- Haskell
    vim.lsp.config("hls", {
      cmd = { "haskell-language-server-wrapper", "--lsp" },
      settings = {
        haskell = {
          formattingProvider = "fourmolu",
          checkParents = "CheckOnSave",
        },
      },
    })

    -- Elixir
    vim.lsp.config("elixirls", {
      cmd = { vim.fn.expand("~/.elixir-ls/release/language_server.sh") },
      settings = {
        elixirLS = {
          dialyzerEnabled = true,
          fetchDeps = true,
        },
      },
    })

    -- Dart/Flutter
    vim.lsp.config("dartls", {
      cmd = { vim.fn.expand("~/Flutter/bin/dart"), "language-server", "--lsp", "--protocol=analyzer" },
      settings = {
        dart = {
          analysisExcludedFolders = { ".dart_tool", "build" },
          completeFunctionCalls = true,
          renameFilesWithClasses = "always",
          enableSnippets = true,
        },
      },
    })

    -- Only enable servers whose binary is actually present. Check absolute
    -- paths with fs_stat (instant) — NEVER vim.fn.executable()/exepath(),
    -- which scan the Windows PATH over 9p on WSL (~116ms per missing binary,
    -- paid on every buffer open). ts_ls/svelte/hls were enabled but not
    -- installed, costing ~350ms per file open; re-add them below with an
    -- absolute cmd once their servers are installed.
    local function have(p) return vim.uv.fs_stat(vim.fn.expand(p)) ~= nil end
    local servers = {}
    local checks = {
      { "pyright",       "~/.local/bin/pyright-langserver" },
      { "gopls",         "~/go/bin/gopls" },
      { "dartls",        "~/Flutter/bin/dart" },
      { "rust_analyzer", "~/.local/bin/rust-analyzer" },
      { "elixirls",      "~/.elixir-ls/release/language_server.sh" },
    }
    for _, c in ipairs(checks) do
      if have(c[2]) then servers[#servers + 1] = c[1] end
    end
    vim.lsp.enable(servers)
  end,
}

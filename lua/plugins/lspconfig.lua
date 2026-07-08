-- LSP core
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = function()
    -- Skip LSP log IO entirely: the default WARN level still writes every
    -- server stderr line to lsp.log, which is pure overhead on chatty servers.
    vim.lsp.set_log_level("off")

    -- Servers (pyright especially) emit docstrings as escaped markdown:
    -- "&nbsp;" for indentation and backslash-escaped punctuation ("base\_url"),
    -- which the float renders literally. Clean those up before rendering.
    -- This function feeds hover and signature help; fenced code blocks are
    -- left untouched (they're shown verbatim, unescaping would corrupt them).
    local orig_convert = vim.lsp.util.convert_input_to_markdown_lines
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.lsp.util.convert_input_to_markdown_lines = function(input, contents)
      local lines = orig_convert(input, contents)
      local fenced = false
      for i, line in ipairs(lines) do
        if line:find("^%s*```") then
          fenced = not fenced
        elseif not fenced then
          lines[i] = line
            :gsub("&nbsp;", " ")
            :gsub("&lt;", "<")
            :gsub("&gt;", ">")
            :gsub("&amp;", "&")
            :gsub("\\([\\`*_{}%[%]()#+%-%.!<>|])", "%1")
        end
      end
      return lines
    end

    -- LSP capabilities. NOTE: default_capabilities() takes an *options*
    -- override, not a base table — passing make_client_capabilities() into it
    -- (as this config used to) silently discarded every non-completion
    -- capability. Merge instead.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if cmp_ok then
      capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
    end

    -- Don't offer client-side file watching. When a server registers for it,
    -- core loads vim.lsp._watchfiles, which (a) probes for inotifywait with
    -- vim.fn.executable() — the 9p Windows-PATH scan — and (b) inotifywait
    -- isn't installed here, so it falls back to a Lua poller that recursively
    -- scans and stat-polls the whole workspace: seconds of blocking at attach
    -- on a big repo plus constant background CPU. Without the capability,
    -- pyright/gopls/rust-analyzer use their own native watchers instead.
    capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = false }

    -- Don't request semantic tokens: the server computes a full-file token
    -- set on open and after edits, stealing time from definition/completion
    -- requests. Treesitter already provides highlighting.
    capabilities.textDocument.semanticTokens = nil

    vim.lsp.config("*", {
      capabilities = capabilities,
      -- Batch didChange notifications a bit more (default 150ms) so servers
      -- re-analyze less often while typing, keeping them responsive for gd.
      flags = { debounce_text_changes = 250 },
    })

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

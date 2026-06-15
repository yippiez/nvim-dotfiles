-- Byte-compiled Lua module cache. Speeds up every require() (plugins, LSP,
-- telescope, treesitter) on later launches once the cache is warm. Must be the
-- first thing so it covers all subsequent requires. Pure speed, no behavior change.
vim.loader.enable()

-- Set Leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable built-ins
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_tutor = 1

-- Disable unused remote-plugin providers. Probing for these (e.g. has("python3"))
-- scans the Windows PATH over 9p on WSL and costs ~685ms — paid the moment any
-- plugin touches the provider. All plugins here are pure Lua, so none are needed.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.opt.lazyredraw = true
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 50
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.foldmethod = "manual"
vim.opt.viewoptions = "folds,cursor"
vim.opt.autoread = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.synmaxcol = 200

-- Clipboard support
-- NOTE: do NOT probe with vim.fn.executable("win32yank.exe") here — on WSL that
-- scans the whole Windows PATH (75+ /mnt/c entries) over the 9p filesystem and
-- costs ~500ms at startup. win32yank is resolved lazily on first yank instead.
--
-- COPY via OSC52 (a terminal escape, zero process spawn) instead of shelling out
-- to win32yank.exe on every yank: with clipboard=unnamedplus, every y/d/c/x
-- writes the + register, and a win32yank spawn blocks ~200ms each time. OSC52 is
-- instant. PASTE still uses win32yank so pulling text from Windows apps works;
-- internal yank->put is served from Neovim's own cache and never spawns.
-- (Requires a terminal that honours OSC52 clipboard writes — Windows Terminal does.)
if vim.fn.has("wsl") == 1 then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "osc52-copy/win32yank-paste",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = { "win32yank.exe", "-o", "--lf" }, ["*"] = { "win32yank.exe", "-o", "--lf" } },
    cache_enabled = true,
  }
end
vim.opt.clipboard = "unnamedplus"

local api = vim.api

-- Large-file guard (used by treesitter, folds, etc.)
local LARGE_FILE_SIZE = 100 * 1024 -- 100 KB
local function is_large_file(bufnr)
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr or 0))
  return ok and stats and stats.size > LARGE_FILE_SIZE
end

-- Save/restore folds
local fold_filetypes = "*.py,*.js,*.ts,*.jsx,*.tsx,*.svelte,*.lua,*.md"
api.nvim_create_autocmd("BufWinLeave", {
  pattern = fold_filetypes,
  callback = function(args)
    if not is_large_file(args.buf) then
      vim.cmd("silent! mkview")
    end
  end,
})
api.nvim_create_autocmd("BufWinEnter", {
  pattern = fold_filetypes,
  callback = function(args)
    if not is_large_file(args.buf) then
      vim.cmd("silent! loadview")
    end
  end,
})

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})

-- Return to last position
api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= api.nvim_buf_line_count(0) then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

local map = vim.keymap.set

-- Basic
map("n", "<Esc>", ":noh<CR>", { silent = true })
map({ "n", "i" }, "<C-s>", "<cmd>w<CR>")
map("n", "<leader>cr", "<cmd>belowright Compile<CR>", { desc = "Run compile mode" })
map("n", "<leader>cq", function()
  require("compile-mode").close_buffer()
end, { desc = "Close compile window" })
map("n", "<leader>bq", ":bdelete<CR>", { desc = "Close buffer" })
map("n", "<leader>bn", ":enew<CR>", { desc = "New buffer" })

-- Git change navigation
map("n", "]c", function()
  require("gitsigns").next_hunk()
end, { desc = "Next git hunk" })
map("n", "[c", function()
  require("gitsigns").prev_hunk()
end, { desc = "Previous git hunk" })

-- LSP
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "References" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>le", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>la", vim.lsp.buf.hover, { desc = "Hover" })
map({ "n", "v" }, "<leader>lf", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map({ "n", "v" }, "<leader>ls", function()
  vim.lsp.buf.code_action({
    filter = function(action)
      local kind = action.kind or ""
      return kind:find("^refactor") ~= nil
    end,
  })
end, { desc = "Refactor (split/join)" })
map("n", "<leader>lc", function()
  local d = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if #d > 0 then
    vim.fn.setreg("+", d[1].message)
    print("Copied: " .. d[1].message)
  end
end, { desc = "Copy diagnostic" })

-- Move lines
map("n", "<M-Up>", ":m .-2<CR>==", { silent = true })
map("n", "<M-Down>", ":m .+1<CR>==", { silent = true })
map("i", "<M-Up>", "<Esc>:m .-2<CR>==gi", { silent = true })
map("i", "<M-Down>", "<Esc>:m .+1<CR>==gi", { silent = true })
map("v", "<M-Up>", ":m '<-2<CR>gv=gv", { silent = true })
map("v", "<M-Down>", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "<M-Left>", "<gv", { silent = true })
map("v", "<M-Right>", ">gv", { silent = true })

-- Command aliases
vim.cmd("command! Wq wq")
vim.cmd("command! W w")
vim.cmd("command! Q q!")
vim.cmd("cnoreabbrev Q! q!")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  -- Colorscheme: Vague (default)
  {
    "vague-theme/vague.nvim",
    priority = 1000,
    config = function()
      require("vague").setup({
        style = { boolean = "none", comments = "none", strings = "none" },
      })
      vim.cmd.colorscheme("vague")
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      -- Cache the listed-buffer count and refresh only when buffers are
      -- added/removed, instead of rebuilding a full getbufinfo() table on every
      -- statusline redraw (which happens on every cursor move / mode change).
      local buf_count = 0
      local function refresh_buf_count()
        buf_count = #vim.fn.getbufinfo({ buflisted = 1 })
      end
      api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufFilePost" }, { callback = refresh_buf_count })
      refresh_buf_count()
      require("lualine").setup({
        options = { icons_enabled = false, section_separators = "", component_separators = "" },
        sections = {
          lualine_a = {
            { "mode" },
            {
              function() return "DEBUG" end,
              cond = function() return _G.hydra_debug_active end,
              color = "DiagnosticOk",
            },
          },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            "filename",
          },
          lualine_x = {
            function() return "bufs:" .. buf_count end,
          },
          lualine_y = { "filetype" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        preset = "modern",
        win = {
          title = false,
          border = "rounded",
          width = 0.99,
          col = 0,
        },
        icons = { mappings = false },
      })
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "┃" }, change = { text = "┃" }, delete = { text = "_" },
          topdelete = { text = "‾" }, changedelete = { text = "~" }, untracked = { text = "┆" },
        },
      })
    end,
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({
        signs = false,
        keywords = {
          FIX = { icon = "F", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          TODO = { icon = "T", color = "info" },
          HACK = { icon = "H", color = "warning" },
          WARN = { icon = "W", color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = "P", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = "N", color = "hint", alt = { "INFO" } },
          TEST = { icon = "T", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
          FACT = { icon = "F", color = "error" },
        },
      })
    end,
  },

  -- LSP Lens
  {
    "VidocqH/lsp-lens.nvim",
    event = "LspAttach",
    config = function()
      require("lsp-lens").setup({
        sections = { definition = false, references = true, implements = true, git_authors = false },
        ignore_filetype = { "prisma" },
      })
    end,
  },

  -- LSP core
  {
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
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    -- Preload just after startup (invisible to the user) so the FIRST <leader>ff
    -- is as instant as later ones — no lazy-load chain stall on the keypress.
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      -- Compiled C sorter: ranks/filters large result sets far faster than the
      -- default Lua sorter (this is what made the first list slow to populate).
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", "%.git/" },
          layout_strategy = "bottom_pane",
          layout_config = { bottom_pane = { height = 0.4, prompt_position = "bottom" } },
          previewer = false,
        },
        pickers = { find_files = { disable_devicons = true }, buffers = { disable_devicons = true } },
        extensions = {
          fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
        },
      })
      pcall(telescope.load_extension, "fzf")
      local builtin = require("telescope.builtin")
      local custom_find_files = function()
        builtin.find_files({
          -- fd is purpose-built for file enumeration and faster than `rg --files`.
          find_command = { "fd", "--type", "f", "--color", "never", "--hidden", "--ignore-file", ".jjignore" },
        })
      end
      local custom_live_grep = function()
        builtin.live_grep({
          additional_args = { "--hidden", "--ignore-file", ".jjignore" },
        })
      end
      map("n", "<leader>ff", custom_find_files, { desc = "Find files" })
      map("n", "<leader>fg", custom_live_grep, { desc = "Live grep" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      map("n", "<leader>fc", builtin.commands, { desc = "Commands" })
      map("n", "<leader>fS", builtin.git_status, { desc = "Git status" })
      map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
      map("n", "<leader>fB", builtin.git_bcommits, { desc = "Buffer commits" })
    end,
  },

  -- Flash 
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      local flash = require("flash")
      flash.setup({})
      map({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash" })
      map({ "n", "x", "o" }, "S", flash.treesitter, { desc = "Flash Treesitter" })
      map("o", "r", flash.remote, { desc = "Remote Flash" })
      map({ "o", "x" }, "R", flash.treesitter_search, { desc = "Treesitter Search" })
      map("c", "<C-s>", flash.toggle, { desc = "Toggle Flash Search" })
    end,
  },

  -- Oil
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = { { "<leader>o", "<cmd>Oil<CR>", desc = "Open Oil" } },
    -- Hijack directories opened directly (e.g. `nvim .`) since netrw is disabled
    init = function()
      api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.isdirectory(vim.fn.expand("%:p")) == 1 then
            vim.cmd("Oil")
          end
        end,
      })
    end,
    config = function()
      require("oil").setup({
        columns = { "size" },
        view_options = { show_hidden = true },
        watch_for_changes = true,
        keymaps = { ["<C-p>"] = false, ["<C-i>"] = "actions.preview" },
      })
    end,
  },

  -- Comment
  {
    "numToStr/Comment.nvim",
    keys = { { "<leader>cc", mode = { "n", "v" } } },
    config = function()
      local comment = require("Comment")
      comment.setup({
        mappings = {
          basic = false,
          extra = false,
        },
      })
      local comment_api = require("Comment.api")
      map("n", "<leader>cc", comment_api.toggle.linewise.current, { desc = "Toggle comment" })
      map("v", "<leader>cc", function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
        comment_api.toggle.linewise(vim.fn.visualmode())
      end, { desc = "Toggle comment" })
    end,
  },

  -- TreeSJ (split/join)
  {
    "Wansmer/treesj",
    keys = { "<leader>ls", "<leader>lS" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local tsj = require("treesj")
      tsj.setup({ use_default_keymaps = false })
      map("n", "<leader>ls", tsj.toggle, { desc = "Toggle split/join" })
      map("n", "<leader>lS", function() tsj.toggle({ split = { recursive = true } }) end, { desc = "Toggle recursive" })
    end,
  },

  -- Compile Mode
  {
    "ej-shafran/compile-mode.nvim",
    version = "^5.0.0",
    cmd = { "Compile", "Recompile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.g.compile_mode = {
        default_command = {
          rust = "cargo run",
          python = "uv run %",
          dart = "flutter analyze",
          ["*"] = "make -k ",
        },
        bang_expansion = true,
        use_diagnostics = false,
        focus_compilation_buffer = true,
      }
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    -- Preload just after startup (invisible) rather than on the first keystroke,
    -- so the first time you enter insert mode there's no ~25ms cmp-load hitch.
    event = "VeryLazy",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer", keyword_length = 3, max_item_count = 10 },
          { name = "path" },
        }),
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() then
              cmp.confirm({ select = false })
            else
              cmp.abort()
              fallback()
            end
          end),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-f>"] = cmp.mapping.scroll_docs(-4),
          ["<M-.>"] = cmp.mapping.complete(),
        }),
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Pre-install parsers for languages actually used here so opening one of
        -- these files never pays the ~475ms compile-on-first-open that
        -- auto_install incurs for a missing parser. auto_install still covers
        -- anything not listed.
        ensure_installed = {
          "lua", "vim", "vimdoc", "python", "javascript", "typescript", "tsx",
          "dart", "latex", "rust", "go", "gomod", "elixir", "haskell",
          "json", "yaml", "toml", "html", "css", "bash", "markdown", "markdown_inline",
        },
        auto_install = true,
        highlight = {
          enable = true,
          disable = function(_, bufnr)
            if is_large_file(bufnr) then
              -- Fall back to regex syntax for large files
              vim.bo[bufnr].syntax = vim.bo[bufnr].filetype
              return true
            end
          end,
        },
        indent = {
          enable = true,
          disable = function(_, bufnr)
            return is_large_file(bufnr)
          end,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = false,
            node_decremental = "grm",
          },
        },
      })
    end,
  },

  -- Auto-detect indentation
  {
    "NMAC427/guess-indent.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "GuessIndent",
    config = function()
      require("guess-indent").setup({})
    end,
  },
}

require("lazy").setup(plugins, {
  install = { missing = true, colorscheme = { "vague" } },
  checker = { enabled = true, notify = false },
  change_detection = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    source = "always",
    prefix = "●",
    format = function(d)
      local msg = d.message:gsub("\n", " ")
      return #msg > 50 and msg:sub(1, 47) .. "..." or msg
    end,
  },
  float = { source = "always", wrap = true, border = "rounded" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Quickeys: insert comment line with language-appropriate syntax
map("n", "<leader>qc", function()
  local cs = vim.bo.commentstring
  if not cs or cs == "" then
    local ft_leaders = {
      python = "#", sh = "#", bash = "#", zsh = "#",
      lua = "--", sql = "--", haskell = "--",
      javascript = "//", typescript = "//", javascriptreact = "//",
      typescriptreact = "//", c = "//", cpp = "//", rust = "//",
      go = "//", java = "//", dart = "//", kotlin = "//", swift = "//",
      yaml = "#", ruby = "#", elixir = "#", toml = "#", conf = "#",
      make = "#", vim = '"', fennel = ";", clojure = ";", lisp = ";",
      tex = "%", matlab = "%", erlang = "%",
      css = "/*", html = "<!--", xml = "<!--",
    }
    cs = (ft_leaders[vim.bo.filetype] or "#") .. " %s"
  end

  local c_leader = cs:match("^(.-)%%s")
  c_leader = c_leader and vim.trim(c_leader) or "#"

  local indent = vim.fn.getline("."):match("^(%s*)") or ""
  local comment_line = indent .. c_leader .. " ... "

  local lnum = vim.fn.line(".")
  vim.fn.append(lnum - 1, comment_line)
  vim.fn.cursor(lnum, #comment_line + 1)
end, { desc = "Comment before cursor" })

map("n", "<leader>qt", function()
  local cs = vim.bo.commentstring
  if not cs or cs == "" then
    local ft_leaders = {
      python = "#", sh = "#", bash = "#", zsh = "#",
      lua = "--", sql = "--", haskell = "--",
      javascript = "//", typescript = "//", javascriptreact = "//",
      typescriptreact = "//", c = "//", cpp = "//", rust = "//",
      go = "//", java = "//", dart = "//", kotlin = "//", swift = "//",
      yaml = "#", ruby = "#", elixir = "#", toml = "#", conf = "#",
      make = "#", vim = '"', fennel = ";", clojure = ";", lisp = ";",
      tex = "%", matlab = "%", erlang = "%",
      css = "/*", html = "<!--", xml = "<!--",
    }
    cs = (ft_leaders[vim.bo.filetype] or "#") .. " %s"
  end

  local c_leader = cs:match("^(.-)%%s")
  c_leader = c_leader and vim.trim(c_leader) or "#"

  local indent = vim.fn.getline("."):match("^(%s*)") or ""
  local comment_line = indent .. c_leader .. " TODO: "

  local lnum = vim.fn.line(".")
  vim.fn.append(lnum - 1, comment_line)
  vim.fn.cursor(lnum, #comment_line + 1)
  vim.cmd("startinsert!")
end, { desc = "Todo comment before cursor" })

map("n", "<leader>qo", function()
  local indent = vim.fn.getline("."):match("^(%s*)") or ""
  local lnum = vim.fn.line(".")
  vim.fn.append(lnum - 1, indent)
end, { desc = "New line before cursor" })





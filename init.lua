
-- ============================================================================
-- Basic Settings
-- ============================================================================

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

-- ============================================================================
-- Options
-- ============================================================================

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

-- Clipboard (non-WSL)
if vim.fn.has("wsl") ~= 1 then
  vim.opt.clipboard = "unnamedplus"
end

-- WSL clipboard support
if vim.fn.has("wsl") == 1 then
  local win32yank = "/mnt/c/dev/custom_commands/win32yank.exe"
  if vim.fn.executable(win32yank) == 1 then
    vim.g.clipboard = {
      name = "win32yank-wsl",
      copy = { ["+"] = { win32yank, "-i", "--crlf" }, ["*"] = { win32yank, "-i", "--crlf" } },
      paste = { ["+"] = { win32yank, "-o", "--lf" }, ["*"] = { win32yank, "-o", "--lf" } },
      cache_enabled = true,
    }
    vim.opt.clipboard = "unnamedplus"
  end
end

-- Filetype detection
vim.filetype.add({ extension = { svelte = "svelte" } })

-- ============================================================================
-- Autocmds
-- ============================================================================

local api = vim.api

-- Check for external file changes
api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})

-- Save/restore folds
local fold_filetypes = "*.py,*.js,*.ts,*.jsx,*.tsx,*.svelte,*.lua,*.md"
api.nvim_create_autocmd("BufWinLeave", {
  pattern = fold_filetypes,
  command = "silent! mkview",
})
api.nvim_create_autocmd("BufWinEnter", {
  pattern = fold_filetypes,
  command = "silent! loadview",
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

-- ============================================================================
-- Keymaps
-- ============================================================================

local map = vim.keymap.set

-- Basic
map("i", "jk", "<Esc>")
map("n", "<Esc>", ":noh<CR>", { silent = true })
map({ "n", "i" }, "<C-s>", "<cmd>w<CR>")

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
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
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

-- ============================================================================
-- Plugin Manager (lazy.nvim)
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Plugins
-- ============================================================================

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

  -- Colorscheme: Tokyo Night
  { "folke/tokyonight.nvim", lazy = true },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    config = function()
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
            function() return "bufs:" .. #vim.fn.getbufinfo({ buflisted = 1 }) end,
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
    lazy = false,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules" },
          layout_strategy = "bottom_pane",
          layout_config = { bottom_pane = { height = 0.4, prompt_position = "bottom" } },
          previewer = false,
        },
        pickers = { find_files = { disable_devicons = true }, buffers = { disable_devicons = true } },
      })
      local builtin = require("telescope.builtin")
      local custom_find_files = function()
        builtin.find_files({
          find_command = { "rg", "--files", "--color=never", "--ignore-file", ".gitignore" },
        })
      end
      map("n", "<leader>ff", custom_find_files, { desc = "Find files" })
      map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      map("n", "<leader>fc", builtin.commands, { desc = "Commands" })
      map("n", "<leader>fS", builtin.git_status, { desc = "Git status" })
      map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
      map("n", "<leader>fB", builtin.git_bcommits, { desc = "Buffer commits" })
    end,
  },

  -- Flash (navigation)
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

  -- Oil (file manager)
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
        columns = { "size" },
        view_options = { show_hidden = true },
        keymaps = { ["<C-p>"] = false, ["<C-i>"] = "actions.preview" },
      })
      map("n", "<leader>o", ":Oil<CR>", { desc = "Open Oil" })
    end,
  },

  -- Comment
  {
    "numToStr/Comment.nvim",
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

  -- Multiple cursors
{
    "nvimtools/hydra.nvim",
    config = function()
      local Hydra = require("hydra")
      Hydra({
        name = "Window",
        mode = "n",
        body = "<C-w>",
        heads = {
          { "h", "<C-w>h" },
          { "j", "<C-w>j" },
          { "k", "<C-w>k" },
          { "l", "<C-w>l" },
          { "H", "<C-w>H" },
          { "J", "<C-w>J" },
          { "K", "<C-w>K" },
          { "L", "<C-w>L" },
          { "v", "<C-w>v" },
          { "s", "<C-w>s" },
          { "q", nil, { exit = true } },
          { "<Esc>", nil, { exit = true } },
        },
        hint = {
          float_opts = {
            border = "rounded",
          },
        },
      })
    end,
  },

  -- TreeSJ (split/join)
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local tsj = require("treesj")
      tsj.setup({ use_default_keymaps = false })
      map("n", "<leader>ls", tsj.toggle, { desc = "Toggle split/join" })
      map("n", "<leader>lS", function() tsj.toggle({ split = { recursive = true } }) end, { desc = "Toggle recursive" })
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, { name = "buffer" }, { name = "path" },
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

  -- Copilot
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<Right>",
            accept_word = "<C-Right>",
            next = "<S-Down>",
            prev = "<S-Up>",
          },
        },
        panel = { enabled = false },
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "python", "javascript", "typescript" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
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

  -- DAP (Debugger)
  {
    "mfussenegger/nvim-dap",
    dependencies = { "nvim-neotest/nvim-nio" },
    config = function()
      local dap = require("dap")

      -- Signs
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◉", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticHint" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "DiffAdd" })

      -- Python adapter
      dap.adapters.python = {
        type = "executable",
        command = vim.fn.exepath("python3"),
        args = { "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file (uv)",
          program = "${file}",
          pythonPath = function()
            local venv = vim.fn.getcwd() .. "/.venv/bin/python"
            if vim.fn.executable(venv) == 1 then return venv end
            return vim.fn.exepath("python3")
          end,
        },
        {
          type = "python",
          request = "launch",
          name = "Launch file (system)",
          program = "${file}",
          pythonPath = vim.fn.exepath("python3"),
        },
      }
    end,
  },

  -- DAP View
  {
    "igorlfs/nvim-dap-view",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dapview = require("dap-view")
      dapview.setup({
        winbar = {
          sections = { "console", "watches", "scopes", "exceptions", "breakpoints", "threads", "repl" },
        },
      })
      local dap = require("dap")
      dap.listeners.after.event_initialized["dapview"] = function() dapview.open() end
      dap.listeners.before.event_terminated["dapview"] = function() dapview.close() end
      dap.listeners.before.event_exited["dapview"] = function() dapview.close() end
    end,
  },

  -- Hydra (sticky keymaps)
  {
    "nvimtools/hydra.nvim",
    config = function()
      local Hydra = require("hydra")
      local dap = require("dap")

      local function set_debug_active(active)
        _G.hydra_debug_active = active
        local ok, lualine = pcall(require, "lualine")
        if ok then lualine.refresh() end
      end

      Hydra({
        name = "Debug",
        mode = "n",
        body = "<leader>md",
        heads = {
          { "t", dap.toggle_breakpoint },
          { "c", dap.continue },
          { "R", dap.restart },
          { "T", dap.terminate },
          { "o", dap.step_over },
          { "m", dap.step_into },
          { "q", dap.step_out },
          { "r", dap.run_to_cursor },
          { "u", dap.repl.toggle },
          { "C", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end },
          { "<leader>md", nil, { exit = true } },
          { "Q", nil, { exit = true } },
          { "<Esc>", nil, { exit = true } },
        },
        config = {
          color = "pink",
          invoke_on_body = true,
          on_enter = function() set_debug_active(true) end,
          on_exit = function() set_debug_active(false) end,
          hint = false,
        },
      })
    end,
  },

  -- Iron (REPL)
  {
    "Vigemus/iron.nvim",
    config = function()
      local iron = require("iron.core")
      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = { command = { "python3" } },
            zsh = { command = { "zsh" } },
          },
          repl_open_cmd = "vertical botright 50% split",
        },
        keymaps = {},
        highlight = { italic = true },
        ignore_blank_lines = true,
      })

      local function toggle_repl(size)
        iron.repl_for(vim.bo.filetype)
        if size == "full" then
          vim.cmd("wincmd L")
        end
      end

      local function send_block()
        local start_line = vim.fn.search("^# %%", "bnW")
        local end_line = vim.fn.search("^# %%", "nW")
        if start_line == 0 then start_line = 1 else start_line = start_line + 1 end
        if end_line == 0 then end_line = vim.fn.line("$") else end_line = end_line - 1 end
        iron.send(vim.bo.filetype, vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false))
      end

      map("n", "<leader>rr", function() toggle_repl("half") end, { desc = "Toggle REPL (50%)" })
      map("n", "<leader>rR", function() toggle_repl("full") end, { desc = "Toggle REPL (full)" })
      map("n", "<leader>rF", function() iron.repl_restart() end, { desc = "Restart REPL" })
      map("n", "<leader>rl", function() iron.send_line() end, { desc = "Send line" })
      map("v", "<leader>rl", function() iron.visual_send() end, { desc = "Send selection" })
      map("n", "<leader>rb", send_block, { desc = "Send code block" })
      map("n", "<leader>ri", function() iron.send(vim.bo.filetype, string.char(03)) end, { desc = "Interrupt REPL" })
      map("n", "<leader>rf", function() iron.focus_on(vim.bo.filetype) end, { desc = "Focus REPL" })
      map("n", "<leader>rh", function() iron.close_repl(vim.bo.filetype) end, { desc = "Hide REPL" })
      map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
    end,
  },

  -- 99 (AI Agent)
  {
    "ThePrimeagen/99",
    config = function()
      local _99 = require("99")
      local cwd = vim.uv.cwd()
      local basename = vim.fs.basename(cwd)

      _G._99_models = {
        "github-copilot/grok-code-fast-1",
        "opencode/kimi-k2.5-free",
        "openai/gpt-5.2-codex",
      }
      _G._99_current_model = _G._99_models[1]

      _G._99_pick_model = function()
        vim.ui.select(_G._99_models, {
          prompt = "Select 99 model:",
        }, function(choice)
          if choice then
            _G._99_current_model = choice
            print("99 model: " .. choice)
          end
        end)
      end

      _99.setup({
        model = _G._99_current_model,
        completion = {
          custom_rules = {},
          source = "cmp",
        },
        md_files = {
          "AGENT.md",
        },
      })

      local Providers = require("99.providers")
      local original_build = Providers.OpenCodeProvider._build_command
      Providers.OpenCodeProvider._build_command = function(_, query, request)
        request.context.model = _G._99_current_model
        return original_build(_, query, request)
      end

      map("n", "<leader>9f", function() _99.fill_in_function() end, { desc = "99: Fill in function" })
      map("v", "<leader>9v", function() _99.visual() end, { desc = "99: Visual selection" })
      map("n", "<leader>9s", function() _99.stop_all_requests() end, { desc = "99: Stop all requests" })
      map("n", "<leader>9m", function() _G._99_pick_model() end, { desc = "99: Select model" })
      map("n", "<leader>9F", function() _99.fill_in_function_prompt() end, { desc = "99: Fill function (prompt)" })
      map("v", "<leader>9V", function() _99.visual_prompt() end, { desc = "99: Visual selection (prompt)" })
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

-- ============================================================================
-- LSP Configuration 
-- ============================================================================

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

-- LSP capabilities (global)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_ok then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end
vim.lsp.config("*", { capabilities = capabilities })

-- Pyright
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
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

-- Svelte
vim.lsp.config("svelte", {
  settings = {
    svelte = {
      plugin = {
        html = { completions = { enable = true } },
        svelte = { completions = { enable = true } },
        css = { completions = { enable = true, emmet = true } },
      },
    },
  },
})

-- Go
vim.lsp.config("gopls", {
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

vim.lsp.enable({ "pyright", "ts_ls", "rust_analyzer", "svelte", "gopls", "hls" })

-- Auto diagnostic float on CursorHold
api.nvim_create_autocmd("CursorHold", {
  pattern = "*.py,*.js,*.ts,*.jsx,*.tsx,*.svelte,*.go,*.hs",
  callback = function()
    vim.defer_fn(function()
      vim.diagnostic.open_float(nil, { focusable = false })
    end, 1000)
  end,
})

-- ============================================================================
-- Theme Selector
-- ============================================================================

local themes = { "tokyonight", "vague" }
vim.api.nvim_create_user_command("SetTheme", function(opts)
  local theme = opts.args:lower()
  for _, t in ipairs(themes) do
    if t:lower() == theme then
      vim.cmd.colorscheme(t)
      return
    end
  end
  print("Unknown theme: " .. opts.args)
end, {
  nargs = 1,
  complete = function() return themes end,
})

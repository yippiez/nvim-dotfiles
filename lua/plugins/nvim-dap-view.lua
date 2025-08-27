-- https://github.com/igorlfs/nvim-dap-view
return {
  "igorlfs/nvim-dap-view",
  version = false,
  dependencies = { "mfussenegger/nvim-dap" },
  opts = {
    winbar = {
      sections = { "console", "watches", "scopes", "exceptions", "breakpoints", "threads", "repl" },
      base_sections = {
        breakpoints = {
          keymap = "B",
          label = "Breakpoints [B]",
          short_label = "[B]",
          action = function()
            require("dap-view.views").switch_to_view("breakpoints")
          end,
        },
        scopes = {
          keymap = "S",
          label = "Scopes [S]",
          short_label = "[S]",
          action = function()
            require("dap-view.views").switch_to_view("scopes")
          end,
        },
        exceptions = {
          keymap = "E",
          label = "Exceptions [E]",
          short_label = "[E]",
          action = function()
            require("dap-view.views").switch_to_view("exceptions")
          end,
        },
        watches = {
          keymap = "W",
          label = "Watch Expressions [W]",
          short_label = "[W]",
          action = function()
            require("dap-view.views").switch_to_view("watches")
          end,
        },
        threads = {
          keymap = "H",
          label = "Threads [H]",
          short_label = "[H]",
          action = function()
            require("dap-view.views").switch_to_view("threads")
          end,
        },
        repl = {
          keymap = "R",
          label = "REPL [R]",
          short_label = "[R]",
          action = function()
            require("dap-view.repl").show()
          end,
        },
        sessions = {
          keymap = "K",
          label = "Sessions [K]",
          short_label = "[K]",
          action = function()
            require("dap-view.views").switch_to_view("sessions")
          end,
        },
        console = {
          keymap = "O",
          label = "Output [O]",
          short_label = "[O]",
          action = function()
            require("dap-view.term").show()
          end,
        },
      },
      controls = {
        enabled = true,
        position = "right",
        buttons = {
          "play",
          "step_into", 
          "step_over",
          "step_out",
          "step_back",
          "run_last",
          "terminate",
          "disconnect",
        },
      },
    },
    windows = {
      terminal = {
        start_hidden = true, -- Hide the separate terminal split since console is in winbar
      },
    },
    icons = {
      disabled = "○",
      disconnect = "X",
      enabled = "●",
      filter = "▼",
      negate = "!",
      pause = "P",
      play = "▶",
      run_last = "↻",
      step_back = "◀",
      step_into = "↓",
      step_out = "↑",
      step_over = "→",
      terminate = "■",
    },
  },
  config = function(_, opts)
    require("dap-view").setup(opts)

    -- Add Commander entries without keymaps
    local ok, commander = pcall(require, "commander")
    if ok then
      commander.add({
        { desc = "DAP View: Open", cmd = "DapViewOpen", keys = {}, category = "Debug" },
        { desc = "DAP View: Close", cmd = "DapViewClose", keys = {}, category = "Debug" },
        { desc = "DAP View: Toggle", cmd = "DapViewToggle", keys = {}, category = "Debug" },
      })
    end

    -- Auto open on debug start, auto close on end
    local dap_ok, dap = pcall(require, "dap")
    if dap_ok then
      dap.listeners.after.event_initialized["dap-view_autoopen"] = function()
        vim.schedule(function()
          pcall(vim.cmd, "DapViewOpen")
        end)
      end
      dap.listeners.before.event_terminated["dap-view_autoclose"] = function()
        vim.schedule(function()
          pcall(vim.cmd, "DapViewClose")
        end)
      end
      dap.listeners.before.event_exited["dap-view_autoclose"] = function()
        vim.schedule(function()
          pcall(vim.cmd, "DapViewClose")
        end)
      end
    end
  end,
}
-- https://github.com/igorlfs/nvim-dap-view
return {
  "igorlfs/nvim-dap-view",
  version = false,
  dependencies = { "mfussenegger/nvim-dap" },
  opts = {},
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
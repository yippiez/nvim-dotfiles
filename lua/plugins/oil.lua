local api = vim.api

-- Oil
return {
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
}

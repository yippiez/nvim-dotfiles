-- https://github.com/stevearc/oil.nvim
return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    view_options = {
      show_hidden = true,
    },
    -- Show only size column
    columns = {
      "size",
    },
    use_default_keymaps = true,
    keymaps = {
      -- Override C-p to avoid conflict with commander
      ["<C-p>"] = false,
      -- Use different key for preview if needed
      ["<C-i>"] = "actions.preview",
    },
  },
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}

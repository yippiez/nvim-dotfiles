return {
  "brenton-leighton/multiple-cursors.nvim",
  version = "*",  -- Use the latest tagged version
  opts = {},  -- This causes the plugin setup function to be called
  keys = {
    {"gb", mode = {"n", "x"}, "<cmd>MultipleCursorsAddDown<cr>", desc = "Add cursor and move to next occurrence"},
  },
}
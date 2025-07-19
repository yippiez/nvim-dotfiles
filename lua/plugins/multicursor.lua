return {
  "brenton-leighton/multiple-cursors.nvim",
  version = "*",  -- Use the latest tagged version
  opts = {},  -- This causes the plugin setup function to be called
  keys = {
    {"gb", mode = {"n", "x"}, "<cmd>MCstart<cr>", desc = "Create a selection for selected text or word under the cursor"},
  },
}
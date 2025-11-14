-- https://github.com/brenton-leighton/multiple-cursors.nvim
return {
    "brenton-leighton/multiple-cursors.nvim",
    version = "*",  -- Use the latest tagged version
    opts = {},  -- This causes the plugin setup function to be called
    keys = {
        {"gb", mode = {"n", "x"}, "<cmd>MultipleCursorsAddJumpNextMatch<cr>", desc = "Add cursor to next matching word"},
    },
}
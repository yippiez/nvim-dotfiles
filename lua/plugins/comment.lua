local map = vim.keymap.set

-- Comment
return {
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
}

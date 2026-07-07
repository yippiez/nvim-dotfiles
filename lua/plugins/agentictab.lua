return {
  dir = "/home/eren/work2/cursortab.nvim",
  name = "agentictab.nvim",
  -- Load at startup (cheap: no process until the first request) so cmp's
  -- VeryLazy setup wraps agentictab's <Tab> mapping as its fallback.
  lazy = false,
  config = function()
    require("agentictab").setup({
      pi = {
        -- Test model; remove these two lines to use pi's configured default.
        provider = "opencode-go",
        model = "deepseek-v4-flash",
      },
    })
  end,
}

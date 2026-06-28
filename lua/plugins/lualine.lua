local api = vim.api

-- Status line
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()
    -- Cache the listed-buffer count and refresh only when buffers are
    -- added/removed, instead of rebuilding a full getbufinfo() table on every
    -- statusline redraw (which happens on every cursor move / mode change).
    local buf_count = 0
    local function refresh_buf_count()
      buf_count = #vim.fn.getbufinfo({ buflisted = 1 })
    end
    api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufFilePost" }, { callback = refresh_buf_count })
    refresh_buf_count()
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
          function() return "bufs:" .. buf_count end,
        },
        lualine_y = { "filetype" },
        lualine_z = { "location" },
      },
    })
  end,
}

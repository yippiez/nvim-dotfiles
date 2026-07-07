-- Completion
return {
  "hrsh7th/nvim-cmp",
  -- Preload just after startup (invisible) rather than on the first keystroke,
  -- so the first time you enter insert mode there's no ~25ms cmp-load hitch.
  event = "VeryLazy",
  dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path" },
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "buffer", keyword_length = 3, max_item_count = 10 },
        { name = "path" },
      }),
      mapping = cmp.mapping.preset.insert({
        -- Only drive the cmp menu when it's open; otherwise fall through to a
        -- literal <Tab>/<S-Tab>.
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_next_item() else fallback() end
        end),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_prev_item() else fallback() end
        end),
        ["<CR>"] = cmp.mapping(function(fallback)
          if cmp.visible() and cmp.get_selected_entry() then
            cmp.confirm({ select = false })
          else
            cmp.abort()
            fallback()
          end
        end),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-f>"] = cmp.mapping.scroll_docs(-4),
        -- <M-.> belongs to tabagentic (prompt bar); manual complete moved here.
        ["<C-Space>"] = cmp.mapping.complete(),
      }),
    })
  end,
}

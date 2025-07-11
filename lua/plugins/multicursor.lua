return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    -- gb - select word and add cursors to other occurrences
    vim.keymap.set({"n", "x"}, "gb", function() mc.matchAddCursor(1) end, { desc = "Add cursor to next match" })
    
    -- Clear cursors with escape
    mc.addKeymapLayer(function(layerSet)
      layerSet("n", "<esc>", mc.clearCursors)
    end)
  end
}

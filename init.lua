-- Byte-compiled Lua module cache. Speeds up every require()
-- WARNING: Must be set before plugins are loaded
vim.loader.enable()

-- Leader must be set before plugins are loaded
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.lazy")
require("config.diagnostics")

## Repository Structure

This is a modular Neovim configuration using lazy.nvim plugin manager.

### Core Configuration
- `init.lua` - Entry point, loads config modules and sets global options
- `lua/config/` - Core configuration modules
  - `lazy.lua` - Plugin manager setup
  - `keymaps.lua` - Global keybindings
  - `lsp.lua` - Language server configuration
  - `win32yank.lua` - WSL clipboard integration

### Plugins (`lua/plugins/`)
- `colorscheme.lua` - Tokyo Night theme
- `commander.lua` - Command palette (`<C-p>`) with predefined commands
- `comment.lua` - Smart commenting (no keybindings)
- `completion.lua` - nvim-cmp autocompletion with LSP/buffer sources
- `gitsigns.lua` - Git change indicators (visual only)
- `iron.lua` - REPL integration (`<leader>r*` keybindings)
- `lualine.lua` - Status line with git and LSP integration
- `flash.lua` - Fast navigation and jumping (`s`, `S` keys)
- `multicursor.lua` - Multiple cursor editing (`gb` to add cursors)
- `oil.lua` - File manager treating directories as buffers
- `telescope.lua` - Fuzzy finder (integrated with commander)
- `treesitter.lua` - Syntax highlighting (`gnn`, `grn` for selections)
- `which-key.lua` - Keybinding help popup

### Key Features
- **Command Palette**: `<C-p>` opens commander with all main actions
- **File Management**: Oil plugin (`<leader>o`) for directory editing
- **REPL Integration**: Iron plugin for interactive code execution
- **Multiple Cursors**: `gb` adds cursors to matching words
- **Auto-fold Persistence**: Manual folds saved/restored automatically
- **WSL Clipboard**: Integrated clipboard support for Windows

### Global Settings
- 4-space indentation with spaces (no tabs)
- Manual fold method with auto-save/restore
- Tokyo Night colorscheme

### Architecture Notes
- Plugins are completely modular - each file in `lua/plugins/` returns a plugin spec
- Commander plugin centralizes most commands instead of individual keybindings
- LSP configuration is centralized in `lua/config/lsp.lua`
- No custom build/test/lint commands - this is a configuration repository

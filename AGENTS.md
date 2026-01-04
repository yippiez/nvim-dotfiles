## Repository Structure

This is a single-file Neovim configuration using lazy.nvim plugin manager.

### Rules
- When given a github URL fetch it and try to implement the plugin
- After implementing a plugin run nvim headless to test plugin if possible
- Add all plugin specs directly to `init.lua` inside the `require("lazy").setup({...})` block.
- All configuration is contained in `init.lua`.

### Core Configuration
- `init.lua` - Single entry point containing all options, autocmds, keymaps, plugins, and LSP configuration.

### Key Features
- **Fuzzy Finder**: Telescope plugin for file search, live grep, buffers, etc. (`<leader>f*` keybindings)
- **File Management**: Oil plugin (`<leader>o`) for directory editing
- **REPL Integration**: Iron plugin for interactive code execution (`<leader>r*` keybindings)
- **Fast Navigation**: Flash plugin (`s`, `S` keys)
- **Window Management**: Hydra plugin (`<C-w>`)
- **Debugging**: DAP and DAP View with Hydra debug mode (`<leader>md`)
- **Status Line**: Lualine with git and LSP integration
- **AI Completion**: Copilot for intelligent code suggestions
- **Syntax Highlighting**: Treesitter with incremental selection (`gnn`, `grn`)
- **Auto-fold Persistence**: Manual folds saved/restored automatically
- **WSL Clipboard**: Integrated clipboard support for Windows



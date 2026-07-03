## Repository Structure

A modular Neovim configuration using the lazy.nvim plugin manager. `init.lua` is
a thin entry point; everything else lives in `lua/`.

### Layout
- `init.lua` — entry point: enables the loader, sets leader, then requires the
  `config.*` modules.
- `lua/config/options.lua` — disabled built-ins/providers, `vim.opt`, clipboard.
- `lua/config/autocmds.lua` — fold save/restore, yank highlight, last-position.
- `lua/config/keymaps.lua` — standalone keymaps (basic, LSP, move-lines,
  command aliases, quickeys).
- `lua/config/lazy.lua` — bootstraps lazy and `setup({ { import = "plugins" } })`.
- `lua/config/diagnostics.lua` — `vim.diagnostic.config`.
- `lua/util.lua` — shared helpers (e.g. `is_large_file`).
- `lua/plugins/<name>.lua` — **one file per plugin**, each returning a lazy spec.

### Rules
- When given a GitHub URL, fetch it and implement the plugin.
- Add a plugin as a **new file** `lua/plugins/<name>.lua` that `return`s its lazy
  spec — do NOT add specs to `init.lua`.
- Keymaps/autocmds that belong to a plugin go in that plugin's file; standalone
  ones go in `lua/config/keymaps.lua` / `autocmds.lua`.
- After implementing a plugin, run nvim headless to test it if possible.
- WSL performance: never probe with `vim.fn.executable()`/`exepath()`/provider
  `has()` — they scan the Windows PATH over 9p (~100–685 ms each). Check absolute
  paths with `vim.uv.fs_stat` instead.

### Key Features
- **Fuzzy Finder**: Telescope (`<leader>f*`)
- **File Management**: Oil (`<leader>o`)
- **Completion**: nvim-cmp with Tab completion (`<Tab>`)
- **Fast Navigation**: Flash (`s`, `S`)
- **LSP**: nvim-lspconfig (absolute-path gated) + lsp-lens + treesj
- **Status Line**: Lualine with git and LSP integration
- **Syntax Highlighting**: Treesitter with incremental selection (`gnn`, `grn`)
- **Git**: gitsigns (`]c`/`[c`) + todo-comments
- **Auto-fold Persistence**: manual folds saved/restored automatically
- **WSL Clipboard**: OSC52 copy / win32yank paste

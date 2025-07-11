local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- in Insert mode, jk quickly returns you to Normal mode
vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Exit insert mode', silent = true })

-- Save file with Ctrl+S (like other editors)
vim.keymap.set('n', '<C-s>', ':w<CR>', { desc = 'Save file', silent = true })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { desc = 'Save file', silent = true })

-- alias :Wq → :wq
vim.cmd([[ command! Wq wq ]])
-- alias :W  → :w
vim.cmd([[ command! W  w ]])

-- LSP keybindings
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Go to references' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic popup' })

-- Navigate diagnostics/errors
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })

-- Oil file manager
vim.keymap.set('n', '<leader>o', '<CMD>Oil<CR>', { desc = 'Open Oil file manager' })

-- Move lines up/down with Alt+arrow keys (like VSCode)
vim.keymap.set('n', '<M-Up>', ':m .-2<CR>==', { desc = 'Move line up', silent = true })
vim.keymap.set('n', '<M-Down>', ':m .+1<CR>==', { desc = 'Move line down', silent = true })
vim.keymap.set('i', '<M-Up>', '<Esc>:m .-2<CR>==gi', { desc = 'Move line up', silent = true })
vim.keymap.set('i', '<M-Down>', '<Esc>:m .+1<CR>==gi', { desc = 'Move line down', silent = true })
vim.keymap.set('v', '<M-Up>', ':m \'<-2<CR>gv=gv', { desc = 'Move selection up', silent = true })
vim.keymap.set('v', '<M-Down>', ':m \'>+1<CR>gv=gv', { desc = 'Move selection down', silent = true })


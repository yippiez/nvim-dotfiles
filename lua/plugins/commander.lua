-- https://github.com/FeiyouG/commander.nvim
return {
    "FeiyouG/commander.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
        require("commander").setup({
            components = {
                "DESC",
                "KEYS",
            },
            sort_by = {
                "DESC",
            },
            separator = " ",
            auto_replace_desc_with_cmd = false,
            prompt_title = "Commander",
            integration = {
                telescope = {
                    enable = true,
                    theme = function()
                        return {
                            layout_strategy = 'horizontal',
                            layout_config = {
                                width = function(_, max_columns, _)
                                    return math.min(max_columns, 80)
                                end,
                                height = 0.4,
                                prompt_position = 'top',
                                anchor = 'N',
                                preview_cutoff = 0,
                                horizontal = {
                                    preview_width = 0,
                                },
                            },
                            previewer = false,
                            sorting_strategy = 'ascending',
                        }
                    end
                },
                lazy = {
                    enable = false,
                    set_plugin_name_as_cat = false
                }
            }
        })

        -- Add commands
        require("commander").add({
            {
                desc = "Search Files",
                cmd = "<CMD>Telescope find_files<CR>",
                keys = { "n", "<leader>ff" },
                set = false,
            },
            {
                desc = "Search Text",
                cmd = "<CMD>Telescope live_grep<CR>",
                keys = { "n", "<leader>fg" },
                set = false,
            },
            {
                desc = "Search Buffers",
                cmd = "<CMD>Telescope buffers<CR>",
                keys = { "n", "<leader>fb" },
                set = false,
            },
            {
                desc = "Search Commands",
                cmd = "<CMD>Telescope commands<CR>",
                keys = { "n", "<leader>fc" },
                set = false,
            },
            {
                desc = "Search Git Changes",
                cmd = "<CMD>Telescope git_status<CR>",
                keys = { "n", "<leader>fS" },
                set = false,
            },
            {
                desc = "Search Symbols",
                cmd = "<CMD>Telescope lsp_document_symbols<CR>",
                keys = { "n", "<leader>fs" },
                set = false,
            },
            {
                desc = "Search Git Commits",
                cmd = "<CMD>Telescope git_commits<CR>",
                keys = { "n", "<leader>fG" },
                set = false,
            },
            {
                desc = "Search Buffer Commits",
                cmd = "<CMD>Telescope git_bcommits<CR>",
                keys = { "n", "<leader>fB" },
                set = false,
            },
            {
                desc = "Search Todos",
                cmd = "<CMD>TodoTelescope<CR>",
                keys = { "n", "<leader>ft" },
            },
            {
                desc = "Jump to Next Diagnostic",
                cmd = function() vim.diagnostic.goto_next() end,
                keys = { "n", "]d" },
            },
            {
                desc = "Jump to Previous Diagnostic",
                cmd = function() vim.diagnostic.goto_prev() end,
                keys = { "n", "[d" },
            },
            {
                desc = "Jump to Next Todo",
                cmd = function() require("todo-comments").jump_next() end,
                keys = { "n", "]t" },
            },
            {
                desc = "Jump to Previous Todo",
                cmd = function() require("todo-comments").jump_prev() end,
                keys = { "n", "[t" },
            },
            {
                desc = "Open Oil File Manager",
                cmd = "<CMD>Oil<CR>",
                keys = { "n", "<leader>o" },
            },
            {
                desc = "Open New Tab",
                cmd = "<CMD>tabnew<CR>",
            },
            {
                desc = "Open New Buffer",
                cmd = "<CMD>enew<CR>",
            },
            {
                desc = "Open Todo Quickfix",
                cmd = "<CMD>TodoQuickFix<CR>",
            },
            {
                desc = "Preview Hunk Inline",
                cmd = "<CMD>Gitsigns preview_hunk_inline<CR>",
            },
            {
                desc = "Preview Hunk Popup",
                cmd = "<CMD>Gitsigns preview_hunk<CR>",
            },
            {
                desc = "Toggle Line Blame",
                cmd = "<CMD>Gitsigns toggle_current_line_blame<CR>",
            },
            {
                desc = "Enable Line Wrap",
                cmd = "<CMD>set wrap<CR>",
            },
            {
                desc = "Disable Line Wrap", 
                cmd = "<CMD>set nowrap<CR>",
            },
            {
                desc = "Enable Copilot",
                cmd = "<CMD>Copilot enable<CR>",
            },
            {
                desc = "Disable Copilot", 
                cmd = "<CMD>Copilot disable<CR>",
            },
            {
                desc = "Show Copilot Status",
                cmd = "<CMD>Copilot status<CR>",
            },
            {
                desc = "List Buffer Diagnostics",
                cmd = function()
                    vim.diagnostic.setloclist({ bufnr = 0, open = true })
                end,
            },
            {
                desc = "Restart LSP Server",
                cmd = function() 
                    if vim.api.nvim_buf_get_name(0) == "" then return end
                    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
                    if #clients == 0 then return end
                    for _, client in ipairs(clients) do
                        vim.lsp.stop_client(client.id)
                    end
                    vim.cmd("edit")
                end,
            },
            {
                desc = "Change Theme",
                cmd = function() require("config.themes").theme_selector() end,
            },
            {
                desc = "Set Tokyo Night Theme",
                cmd = function() require("config.themes").set_theme("tokyonight") end,
            },
            {
                desc = "Set Vague Theme",
                cmd = function() require("config.themes").set_theme("vague") end,
            },
        })
        
        -- Set keybinding to directly launch commander
        vim.keymap.set("n", "<C-p>", function()
            require("commander").show()
        end, { desc = "Command Palette" })
    end,
}
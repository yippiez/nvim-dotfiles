-- https://github.com/yippiez/oil-git.nvim
return {
    "yippiez/oil-git.nvim",
    ft = "oil",
    dependencies = { "stevearc/oil.nvim" },
    config = function()
        local function set_oil_git_highlights()
            vim.api.nvim_set_hl(0, "OilGitAdded", { fg = "#a6e3a1" })     -- green
            vim.api.nvim_set_hl(0, "OilGitModified", { fg = "#f9e2af" }) -- yellow
            vim.api.nvim_set_hl(0, "OilGitRenamed", { fg = "#cba6f7" })  -- purple
            vim.api.nvim_set_hl(0, "OilGitUntracked", { fg = "#89b4fa" }) -- blue
            vim.api.nvim_set_hl(0, "OilGitIgnored", { fg = "#6c7086" })  -- gray
        end

        require("oil-git").setup({
            prefix = "", -- No space for tight spacing
        })

        -- Set highlights now
        set_oil_git_highlights()

        -- NOTE: Re-apply highlights after colorscheme change to override vague theme
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "*",
            callback = set_oil_git_highlights,
        })
    end,
}

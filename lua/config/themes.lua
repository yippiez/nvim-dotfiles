local M = {}

-- Available themes
M.themes = {
    "tokyonight",
    "vague",
}

-- Get the current theme
function M.get_current()
    local current = vim.g.colors_name
    return current or "tokyonight"
end


function M.set_theme(theme_name)
    -- Sanity Check
    if not vim.tbl_contains(M.themes, theme_name) then
        vim.notify("Theme '" .. theme_name .. "' not found", vim.log.levels.ERROR)
        return false
    end
    
    -- Set the colorscheme
    local ok, err = pcall(vim.cmd.colorscheme, theme_name)
    if not ok then
        vim.notify("Failed to load theme '" .. theme_name .. "': " .. err, vim.log.levels.ERROR)
        return false
    end
    
    vim.notify("Theme changed to: " .. theme_name, vim.log.levels.INFO)
    return true
end

-- Get available themes
function M.get_available()
    return M.themes
end

-- Initialize theme default
function M.init()
    M.set_theme("tokyonight")
end

-- Create theme selector for telescope
function M.theme_selector()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    
    pickers.new({}, {
        prompt_title = "Select Theme",
        finder = finders.new_table({
            results = M.themes,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                M.set_theme(selection[1])
            end)
            return true
        end,
    }):find()
end

return M
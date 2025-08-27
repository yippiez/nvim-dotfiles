return {
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = {
          {
            function()
              if _G.hydra_debug_active then
                return 'DEBUG'
              end
              return require('lualine.utils.mode').get_mode()
            end,
            color = function()
              if _G.hydra_debug_active then
                return { fg = '#ffffff', bg = '#228B22', gui = 'bold' }
              end
              return nil
            end
          }
        },
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {
          function()
            local bufs = #vim.fn.getbufinfo({ buflisted = 1 })
            local ft = vim.bo.filetype or ""
            if ft == "" then
              return string.format("(%dB)", bufs)
            end
            return string.format("(%dB) %s", bufs, ft)
          end,
        },
        lualine_y = {'progress'},
        lualine_z = {{'location', fmt = function(str) return str:gsub(' ', '') end}}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {}
    }
  end
}
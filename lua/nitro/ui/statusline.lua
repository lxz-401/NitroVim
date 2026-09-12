require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = { statusline = {}, winbar = {} },
    always_divide_middle = true,
    globalstatus = true,
    -- 100ms -> 1000ms: 'branch' va 'diff' komponentlari git ma'lumotini
    -- so'raydi; sekundiga 10 marta so'rash Windows'da qimmat.
    refresh = { statusline = 1000, tabline = 1000, winbar = 1000 },
  },
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = function(str)
          return '󱐋 ' .. str
        end,
      },
    },
    lualine_b = {
      'branch',
      'diff',
      {
        'diagnostics',
        sources = { 'nvim_lsp' },
        sections = { 'error', 'warn', 'info', 'hint' },
        colored = true,
        update_in_insert = false,
        always_visible = true,
      }
    },
    lualine_c = {
      {
        'filename',
        file_status = true,
        path = 1,
        fmt = function(name)
          if vim.bo.buftype == 'terminal' then
            return 'Terminal'
          end
          local ok, state = pcall(require, 'nitro-ai.state')
          if ok and state and state.ui and state.ui.tab and vim.api.nvim_tabpage_is_valid(state.ui.tab) and vim.api.nvim_get_current_tabpage() == state.ui.tab then
            local prov_cfg = require('nitro-ai.config').get_current_provider_config()
            local stats = state.get_context_stats()
            local prov_name = (require('nitro-ai.config').options.provider or 'bionic'):upper()
            return string.format("🤖 Model: %s (%s)  📊 Kontekst: %s", prov_cfg.model or "", prov_name, stats.formatted)
          end
          return name
        end,
      },
    },
    -- 'filesize' olib tashlandi: har redraw'da diskdan fayl hajmini o'qirdi
    lualine_x = {
      'encoding',
      'fileformat',
      'filetype',
      'searchcount',
      'selectioncount',
    },
    lualine_y = { 'progress' },
    lualine_z = {
      'location',
      {
        function()
          local clock_icon = ""
          return clock_icon .. " " .. os.date('%H:%M')
        end
      }
    }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = { 'fugitive', 'quickfix' }
}

-- ===========================================================================
--  Plugin ro'yxati (lazy.nvim)
--
--  Qoida: plugin faqat KERAK bo'lganda yuklanadi.
--    event = ...  -> hodisa yuz berganda
--    ft    = ...  -> shu turdagi fayl ochilganda
--    cmd   = ...  -> shu buyruq chaqirilganda
--    keys  = ...  -> shu tugma bosilganda
--    lazy  = true -> require() qilinganda (nitro/* modullari o'zi chaqiradi)
-- ===========================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

local dap_config = require("nitro.core.dap")
local neotest_config = require("nitro.core.neotest")

-- Web fayl turlari (colorizer / autotag uchun)
local web_ft = {
  "html", "css", "scss", "sass", "less",
  "javascript", "javascriptreact", "typescript", "typescriptreact",
  "vue", "svelte", "astro", "xml", "php", "markdown",
}

require("lazy").setup({

  -- File Explorer
  { "nvim-tree/nvim-tree.lua",  dependencies = { "nvim-tree/nvim-web-devicons" }, lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Themes: faqat tanlangani yuklanadi (colorschemes.lua require qiladi)
  { "navarasu/onedark.nvim",    lazy = true },
  { "folke/tokyonight.nvim",    lazy = true },
  { "tanvirtin/monokai.nvim",   lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "catppuccin/nvim",          name = "catppuccin", lazy = true },
  { "Mofiqul/dracula.nvim",     lazy = true },
  { "shaunsingh/nord.nvim",     lazy = true },
  { "sainnhe/everforest",       lazy = true },
  { "rose-pine/neovim",         name = "rose-pine",  lazy = true },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Statusline (statusline.lua o'zi sozlaydi)
  {
    "nvim-lualine/lualine.nvim",
    lazy = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nitro.ui.dashboard")
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  { "nvim-lua/plenary.nvim", lazy = true },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    lazy = true,
    cmd = { "ToggleTerm", "TermExec" },
    -- Faqat plugin O'ZI o'rnatadigan tugmalar bu yerda turishi kerak.
    -- <leader>t keymaps.lua da va :ToggleTerm buyrug'ini chaqiradi ->
    -- plugin yuqoridagi `cmd` orqali yuklanadi.
    keys = { [[<c-\>]], "<leader>lg" },
    config = function()
      local ok, toggleterm = pcall(require, "toggleterm")
      if not ok then
        vim.notify("ToggleTerm not found!", vim.log.levels.WARN)
        return
      end

      -- Terminal oynasi uchun PowerShell.
      -- Global shell ham PowerShell (options.lua ga qarang), lekin bu yerda
      -- aniq ko'rsatamiz: -NoLogo ochilishdagi keraksiz matnni olib tashlaydi.
      local function terminal_shell()
        if vim.fn.executable("pwsh") == 1 then
          return "pwsh -NoLogo"       -- PowerShell 7+
        elseif vim.fn.executable("powershell") == 1 then
          return "powershell -NoLogo" -- Windows PowerShell 5
        end
        return vim.o.shell
      end

      toggleterm.setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = false,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
        shell = terminal_shell(),
        float_opts = {
          border = "curved",
          width = math.floor(vim.o.columns * 0.9),
          height = math.floor(vim.o.lines * 0.9),
          winblend = 5,
        },
      })

      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = {
          border = "curved",
          width = math.floor(vim.o.columns * 0.9),
          height = math.floor(vim.o.lines * 0.9),
        },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = term.bufnr, silent = true })
        end,
        on_close = function()
          vim.cmd("startinsert!")
        end,
      })

      function _LAZYGIT_TOGGLE()
        if vim.fn.executable("lazygit") ~= 1 then
          vim.notify("lazygit o'rnatilmagan: winget install JesseDuffield.lazygit", vim.log.levels.WARN)
          return
        end
        lazygit:toggle()
      end

      vim.keymap.set("n", "<leader>lg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>",
        { noremap = true, silent = true, desc = "Toggle LazyGit" })
    end,
  },

  -- LSP + Mason
  -- lazy = false MAJBURIY: vim.lsp.enable() server sozlamalarini
  -- nvim-lspconfig ning lsp/ papkasidan runtimepath orqali topadi.
  -- Lazy qilinsa hech bir til serveri ishga tushmaydi.
  { "neovim/nvim-lspconfig",          lazy = false },
  { "mason-org/mason-lspconfig.nvim", lazy = true },
  { "b0o/schemastore.nvim",           lazy = true },
  { "mason-org/mason.nvim",           lazy = true, cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" } },

  -- Completion (nvim-cmp)
  -- Manbalar (buffer/path/cmdline/luasnip) o'zini cmp'ga ro'yxatdan o'tkazadi,
  -- shuning uchun ular cmp bilan BIRGA yuklanishi shart -> dependencies.
  {
    "hrsh7th/nvim-cmp",
    lazy = true,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
  },
  { "hrsh7th/cmp-nvim-lsp",     lazy = true },
  { "hrsh7th/cmp-buffer",       lazy = true },
  { "hrsh7th/cmp-path",         lazy = true },
  { "hrsh7th/cmp-cmdline",      lazy = true },
  { "saadparwaiz1/cmp_luasnip", lazy = true },
  { "onsails/lspkind.nvim",     lazy = true },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    config = dap_config.setup_dap,
    keys = dap_config.keys,
  },
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = dap_config.setup_dapui,
  },
  { "nvim-neotest/nvim-nio", lazy = true },

  -- Snippets
  -- friendly-snippets LuaSnip'ga bog'landi: aks holda uni hech kim require
  -- qilmaydi va tayyor snippet'lar runtimepath'ga tushmaydi.
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    dependencies = { "rafamadriz/friendly-snippets" },
  },
  { "rafamadriz/friendly-snippets", lazy = true },

  -- Treesitter
  -- MUHIM: "master" branch. "main" branch tree-sitter-cli talab qiladi va
  -- eski API (highlight/indent) ni umuman o'qimaydi -> highlight ishlamaydi.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    lazy = true,
  },

  -- Ranglarni ko'rsatish (#fff -> rangli). Faqat web fayllarda.
  {
    "catgoose/nvim-colorizer.lua",
    ft = web_ft,
    opts = {
      filetypes = web_ft,
      user_default_options = { names = false },
    },
  },

  -- TODO COMMENTS
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Auto Pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Transparent
  { "xiyaowong/transparent.nvim", lazy = true },

  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      -- O'CHIRILDI: har kursor to'xtaganda `git blame` protsessi ishga tushardi.
      -- Windows'da bu eng ko'p sezilgan lag manbalaridan biri.
      -- Kerak bo'lganda <leader>gb bilan yoqing.
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
        ignore_whitespace = false,
      },
      max_file_length = 10000, -- 10k qatordan uzun faylda o'chadi
      update_debounce = 200,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "]h", function() gs.nav_hunk("next") end, "Next Hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Prev Hunk")
        map("n", "<leader>gb", gs.toggle_current_line_blame, "Git blame (yoq/o'chir)")
        map("n", "<leader>gp", gs.preview_hunk, "Hunk'ni ko'rish")
        map("n", "<leader>gr", gs.reset_hunk, "Hunk'ni qaytarish")
      end,
    },
  },

  -- Noice
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
  { "MunifTanjim/nui.nvim",   lazy = true },
  { "rcarriga/nvim-notify",   lazy = true },

  -- Smear Cursor (kursor animatsiyasi)
  -- time_interval = 5 -> sekundiga 200 marta qayta chizish. Windows terminalida
  -- bu juda qimmat. 17 = ~60 FPS, ko'zga bir xil, CPU esa ancha kam.
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      stiffness = 0.8,
      trailing_stiffness = 0.6,
      stiffness_insert_mode = 0.7,
      trailing_stiffness_insert_mode = 0.7,
      damping = 0.95,
      damping_insert_mode = 0.95,
      distance_stop_animating = 0.5,
      time_interval = 17,
      smear_between_buffers = false,
      smear_between_neighbor_lines = false,
      scroll_buffer_space = false,
    },
  },

  -- Vim Surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- Auto Tag (<div> yozilganda </div> qo'shadi)
  {
    "windwp/nvim-ts-autotag",
    ft = web_ft,
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
  },

  -- C# / .NET
  { "hrsh7th/vim-vsnip",   ft = { "cs", "fsharp", "razor" } },
  { "jlcrochet/vim-razor", ft = { "razor", "cshtml" } },
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs", "fsharp", "razor" },
    cmd = "Dotnet",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      require("easy-dotnet").setup()
    end,
  },
  { "folke/snacks.nvim", lazy = true },

  -- Project
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        manual_mode = true,
        detection_methods = { "pattern" },
        patterns = {
          ".git",
          "_darcs",
          ".hg",
          ".bzr",
          ".svn",
          "Makefile",
          "package.json",
          "pyproject.toml",
          "pom.xml",
          "build.gradle",
        },
        ignore_lsp = {},
        exclude_dirs = {},
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = "global",
        datapath = vim.fn.stdpath("data"),
      })

      pcall(function()
        require("telescope").load_extension("projects")
      end)
    end,
  },

  -- Auto Session
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds,localoptions"

      require("auto-session").setup({
        log_level = "error",
        auto_session_enabled = true,
        auto_save_enabled = true,
        auto_restore_enabled = false,
        auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
      })
    end,
  },

  { "simrat39/rust-tools.nvim", ft = "rust" },

  -- NeoScroll (silliq scroll)
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      require("neoscroll").setup()
    end,
  },

  -- Neotest
  {
    "nvim-neotest/neotest",
    lazy = true,
    cmd = "Neotest",
    keys = { "<leader>Tn", "<leader>Tf", "<leader>Ts", "<leader>To" },
    dependencies = neotest_config.dependencies,
    config = neotest_config.setup,
  },

  -- Text Case
  {
    "johmsalas/text-case.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("textcase").setup({})
      pcall(function()
        require("telescope").load_extension("textcase")
      end)
    end,
    keys = {
      "ga",
      { "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
    },
    cmd = {
      "Subs",
      "TextCaseOpenTelescope",
      "TextCaseOpenTelescopeQuickChange",
      "TextCaseOpenTelescopeLSPChange",
      "TextCaseStartReplacingCommand",
    },
  },

  -- editorconfig-vim OLIB TASHLANDI: Neovim 0.9+ da o'rnatilgan (vim.g.editorconfig)

  -- Render markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    opts = {},
  },
  { "nvim-mini/mini.nvim", lazy = true },

  -- Diagnostics (kursor turgan qatorda chiroyli xato matni)
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    config = function()
      -- format: xato matnini ekranga chiqarishdan oldin o'zbekchaga tarjima
      -- qiladi (:XatoTarjima bilan yoqiladi/o'chiriladi)
      require("tiny-inline-diagnostic").setup({
        options = {
          format = require("nitro.core.diagnostics_uz").format,
        },
      })
      vim.diagnostic.config({ virtual_text = false })
    end,
  },

  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
        ui = { winbar = { enabled = false } },
        lightbulb = { enable = false },
        symbol_in_winbar = { enable = false },
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- Indent chiziqlari
  {
    "nvimdev/indentmini.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("indentmini").setup()
    end,
  },

  -- NitroVim AI Agent (Bionic / LM Studio Local AI)
  --
  -- Bu MAHALLIY plugin -- repo ichida emas, alohida papkada turadi.
  -- `enabled` bo'lmasa, repo klon qilingan boshqa kompyuterda lazy.nvim
  -- "papka topilmadi" xatosini berardi. Endi papka bo'lmasa, plugin
  -- ro'yxatdan butunlay chiqib ketadi va config bemalol ishlayveradi.
  {
    dir = "d:/Projects/NitroVim AI Agent",
    name = "nitro-ai",
    enabled = function()
      return (vim.uv or vim.loop).fs_stat("d:/Projects/NitroVim AI Agent") ~= nil
    end,
    cmd = {
      "NitroAI",
      "NitroAIChat",
      "NitroAINewSession",
      "NitroAISessions",
      "NitroAIEdit",
      "NitroAIFix",
      "NitroAIExplain",
      "NitroAIClear",
      "NitroAIAbort",
      "NitroAIProvider",
      "NitroAIBionicStatus",
    },
    keys = {
      { "<leader>aa", desc = "NitroAI: Chat" },
      { "<leader>an", desc = "NitroAI: Yangi sessiya" },
      { "<leader>as", desc = "NitroAI: Sessiyalar ro'yxati" },
      { "<leader>ae", desc = "NitroAI: Kod tahrirlash", mode = { "n", "v" } },
      { "<leader>af", desc = "NitroAI: LSP xatosini tuzatish" },
      { "<leader>ax", desc = "NitroAI: Kodni tushuntirish", mode = { "n", "v" } },
      { "<leader>ap", desc = "NitroAI: Provayder tanlash" },
    },
    config = function()
      require("nitro-ai").setup({
        provider = "bionic",
        providers = {
          bionic = {
            endpoint = "http://127.0.0.1:1234/v1",
            model = "qwen/qwen3.5-9b",
          },
        },
      })
    end,
  },
}, {
  -- lazy.nvim ning o'z sozlamalari
  defaults = { lazy = false },
  install = { colorscheme = { "onedark", "habamax" } },

  -- Config fayllarni doimiy kuzatib turishni o'chiramiz (Windows'da qimmat)
  change_detection = { enabled = false },
  checker = { enabled = false },

  performance = {
    cache = { enabled = true },
    rtp = {
      -- Keraksiz o'rnatilgan vim plugin'lari
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "zipPlugin",
        "tohtml",
        "tutor",
        "rplugin",
        "netrwPlugin",
        "spellfile",
      },
    },
  },
})

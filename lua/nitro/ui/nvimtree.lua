-- ===========================================================================
--  nvim-tree (fayl menejeri)
--
--  Eslatma: ilgari bu faylda bir xil sozlama 3 marta (left/right/center uchun)
--  nusxalangan edi -- ~520 qator. Endi bitta asosiy jadval bor, pozitsiya
--  faqat "view" qismini almashtiradi.
-- ===========================================================================

local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  vim.notify("nvim-tree not found!", vim.log.levels.ERROR)
  return
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

pcall(require, "nvim-web-devicons")

local api = require("nvim-tree.api")

-- ------------------------------------------------------------ pozitsiya eslab qolish
local position_file = vim.fn.stdpath("state") .. "/nvim-tree-position"

local function save_position(position)
  local file = io.open(position_file, "w")
  if file then
    file:write(position)
    file:close()
  end
end

local function read_position()
  local file = io.open(position_file, "r")
  if file then
    local position = file:read("*l")
    file:close()
    if position == "left" or position == "right" or position == "center" then
      return position
    end
  end
  return "center"
end

-- ------------------------------------------------------------------ view qismi
local function build_view(position)
  if position == "center" then
    return {
      side = "left",
      cursorline = true,
      signcolumn = "yes",
      float = {
        enable = true,
        open_win_config = function()
          local screen_w = vim.opt.columns:get()
          local screen_h = vim.opt.lines:get()
          local win_w = math.floor(screen_w * 0.4)
          local win_h = math.floor(screen_h * 0.8)
          return {
            border = "rounded",
            relative = "editor",
            row = math.floor((screen_h - win_h) / 2),
            col = math.floor((screen_w - win_w) / 2),
            width = win_w,
            height = win_h,
          }
        end,
      },
    }
  end

  return {
    width = 35,
    side = position,
    cursorline = true,
    signcolumn = "yes",
    float = { enable = false },
  }
end

-- ------------------------------------------- Windows: `/` ni ham qabul qilish
--
-- nvim-tree papka ajratuvchisi sifatida faqat `package.config:sub(1,1)` ni
-- biladi -- Windows'da bu `\`. Shuning uchun `src/utils/` deb yozilsa u buni
-- papka deb emas, "src/utils/" nomli FAYL deb tushunadi va
-- "Couldn't create file" xatosini beradi.
--
-- Quyida `a` bosilganda kiritilgan matndagi `/` larni `\` ga aylantiramiz.
-- Windows'da `/` fayl nomida umuman ishlatilmaydi, shuning uchun bu xavfsiz.
local function create_node()
  if vim.fn.has("win32") ~= 1 then
    return api.fs.create()
  end

  local orig_input = vim.ui.input
  vim.ui.input = function(opts, on_confirm)
    orig_input(opts, function(value)
      if type(value) == "string" then
        value = value:gsub("/", "\\")
      end
      on_confirm(value)
    end)
  end

  local ok, err = pcall(api.fs.create)
  vim.ui.input = orig_input

  if not ok then
    vim.notify("Yaratib bo'lmadi: " .. tostring(err), vim.log.levels.ERROR)
  end
end

local function on_attach(bufnr)
  api.config.mappings.default_on_attach(bufnr)
  vim.keymap.set("n", "a", create_node, {
    buffer = bufnr,
    noremap = true,
    silent = true,
    nowait = true,
    desc = "nvim-tree: yangi fayl / papka",
  })
end

-- ------------------------------------------------------------- asosiy sozlama
local function build_config(position)
  return {
    on_attach = on_attach,
    view = build_view(position),

    auto_reload_on_write = true,
    disable_netrw = true,
    hijack_cursor = true,
    hijack_netrw = true,
    sync_root_with_cwd = true,

    renderer = {
      indent_width = 2,
      highlight_git = true,
      highlight_opened_files = "none",
      indent_markers = {
        enable = true,
        inline_arrows = true,
        icons = { corner = "└", edge = "│", item = "│", bottom = "─", none = " " },
      },
      icons = {
        webdev_colors = true,
        git_placement = "after",
        show = { file = true, folder = true, folder_arrow = true, git = true, modified = true },
        glyphs = {
          default = "",
          symlink = "",
          modified = "●",
          folder = {
            default = "",
            open = "",
            arrow_open = "",
            arrow_closed = "",
            empty = "",
            empty_open = "",
          },
          git = {
            unstaged = "",
            staged = "✓",
            unmerged = "",
            renamed = "➜",
            untracked = "★",
            deleted = "",
            ignored = "◌",
          },
        },
      },
      root_folder_label = function(path)
        return "󰋜 " .. vim.fn.fnamemodify(path, ":t")
      end,
      special_files = { "README.md", "Makefile", "Cargo.toml", "package.json", "pom.xml", "pyproject.toml" },
    },

    hijack_directories = { enable = true, auto_open = true },

    -- update_root = false: har fayl ochilganda loyiha ildizini qayta
    -- hisoblamaydi (katta monorepo'da sezilarli tezlik)
    update_focused_file = { enable = true, update_root = false },

    -- Og'ir papkalarni yashiramiz. Ko'rsatish uchun tree ichida "U" bosing.
    filters = {
      dotfiles = false,
      git_ignored = false,
      custom = {
        "^node_modules$",
        "^__pycache__$",
        "^%.venv$",
        "^venv$",
        "^%.mypy_cache$",
        "^%.pytest_cache$",
        "^%.next$",
        "^%.turbo$",
        "^%.gradle$",
        "^target$",
        "^%.git$",
      },
    },

    -- Windows'da fayl kuzatuvchilari qimmat; yozganda baribir yangilanadi
    filesystem_watchers = { enable = false },

    -- git status: timeout qisqartirildi, papkalarda ko'rsatilmaydi
    git = {
      enable = true,
      ignore = false,
      show_on_dirs = false,
      show_on_open_dirs = false,
      timeout = 200,
    },

    -- show_on_dirs = false: har diagnostika kelganda butun daraxt qayta
    -- chizilishining oldini oladi
    diagnostics = {
      enable = true,
      show_on_dirs = false,
      show_on_open_dirs = false,
      debounce_delay = 200,
      icons = { hint = "󰌵", info = "󰋼", warning = "", error = "" },
    },

    actions = {
      use_system_clipboard = true,
      change_dir = { enable = true },
      open_file = {
        quit_on_open = false,
        resize_window = true,
        window_picker = {
          enable = true,
          picker = "default",
          chars = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ",
          exclude = {
            filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
            buftype = { "nofile", "terminal", "help" },
          },
        },
      },
      remove_file = { close_window = false },
    },

    trash = { cmd = "trash", require_confirm = true },

    live_filter = { prefix = "╭─🔍 ", always_show_folders = true },

    notify = { threshold = vim.log.levels.WARN },
  }
end

nvim_tree.setup(build_config(read_position()))

-- ------------------------------------------------------------------- keymap'lar
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>",
  vim.tbl_extend("force", opts, { desc = "Explorer ochish/yopish" }))
vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>",
  vim.tbl_extend("force", opts, { desc = "Explorer'ni yangilash" }))
vim.keymap.set("n", "<leader>n", "<cmd>NvimTreeFindFile<CR>",
  vim.tbl_extend("force", opts, { desc = "Joriy faylni topish" }))
vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<CR>",
  vim.tbl_extend("force", opts, { desc = "Explorer'ga o'tish" }))

vim.cmd([[
  highlight NvimTreeNormal guibg=NONE ctermbg=NONE
  highlight NvimTreeNormalNC guibg=NONE ctermbg=NONE
  highlight NvimTreeGitNew guifg=#3EEA4D
  highlight NvimTreeGitDeleted guifg=#F44747
  highlight NvimTreeGitDirty guifg=#F0A500
  highlight NvimTreeLiveFilterPrefix guifg=#FFFFFF guibg=#5E81AC gui=bold
  highlight NvimTreeLiveFilterValue guifg=#ECEFF4 guibg=#434C5E gui=bold,italic
  highlight NvimTreeLiveFilterBorder guifg=#5E81AC guibg=NONE gui=bold
]])

-- `nvim <papka>` bilan ochilganda daraxtni ko'rsatish
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      vim.cmd.cd(data.file)
      api.tree.open()
    end
  end,
})

-- Faqat daraxt qolganda Neovim'ni yopish
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local tree_wins, floating_wins = {}, {}
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
      if bufname:match("NvimTree_") then table.insert(tree_wins, w) end
      if vim.api.nvim_win_get_config(w).relative ~= "" then table.insert(floating_wins, w) end
    end
    if 1 == #wins - #floating_wins - #tree_wins then
      for _, w in ipairs(tree_wins) do vim.api.nvim_win_close(w, true) end
    end
  end,
})

-- :FileExplorer left|right|center
vim.api.nvim_create_user_command("FileExplorer", function(cmd_opts)
  local arg = cmd_opts.args:lower()

  if arg ~= "left" and arg ~= "right" and arg ~= "center" then
    vim.notify("Ishlatish: :FileExplorer {left|right|center}", vim.log.levels.WARN)
    return
  end

  save_position(arg)
  nvim_tree.setup(build_config(arg))
  vim.cmd("NvimTreeOpen")
end, {
  nargs = 1,
  complete = function() return { "left", "right", "center" } end,
  desc = "Explorer pozitsiyasini o'zgartirish",
})

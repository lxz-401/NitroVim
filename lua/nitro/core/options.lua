vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = " "
vim.opt.fillchars:append({ eob = " " })
vim.o.autoread = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 5
vim.opt.splitbelow = true
vim.opt.splitright = true

-- signcolumn doim ochiq: diagnostika/git belgisi kelganda oyna "sakramaydi"
vim.opt.signcolumn = "yes"

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Performance
vim.opt.updatetime = 250   -- CursorHold / LSP javob tezligi
vim.opt.timeoutlen = 400   -- leader ketma-ketligini kutish
vim.opt.ttimeoutlen = 10   -- ESC kechikishi (terminalda sezilarli)
vim.opt.redrawtime = 1500  -- syntax redraw'ni cheklaydi, "osilib qolish"ni oldini oladi
vim.opt.synmaxcol = 300    -- uzun qatorlarda highlight'ni to'xtatadi (minified fayllar)

-- ---------------------------------------------------------------------------
-- Shell: PowerShell (rasmiy retsept -- :help shell-powershell, :help shell-pwsh)
--
-- Bu GLOBAL sozlama: :!buyruq, :terminal va shell orqali ishlaydigan
-- plugin'lar ham PowerShell ishlatadi.
--
-- BITTA ISTISNO: `:TSInstallSync` cmd sintaksisiga bog'langan va PowerShell'da
-- ishlamaydi. Oddiy `:TSInstall` (asinxron) esa shell'dan o'tmaydi -- u ishlaydi.
-- Zarur bo'lsa :UseCmdShell bilan vaqtincha cmd.exe ga qayting, keyin
-- :UsePowerShell bilan qaytaring.
-- ---------------------------------------------------------------------------
local function use_powershell()
  local exe
  if vim.fn.executable("pwsh") == 1 then
    exe = "pwsh" -- PowerShell 7+
  elseif vim.fn.executable("powershell") == 1 then
    exe = "powershell" -- Windows PowerShell 5
  else
    return false
  end

  local flags = {
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command",
    "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();",
    "$PSDefaultParameterValues['Out-File:Encoding']='utf8';",
  }
  if exe == "pwsh" then
    table.insert(flags, "$PSStyle.OutputRendering='PlainText';")
    vim.env.__SuppressAnsiEscapeSequences = 1
  end

  vim.o.shell = exe
  vim.o.shellcmdflag = table.concat(flags, " ")
  vim.o.shellpipe = "> %s 2>&1"
  vim.o.shellredir = "> %s 2>&1"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
  return true
end

local function use_cmd()
  vim.o.shell = "cmd.exe"
  vim.o.shellcmdflag = "/s /c"
  vim.o.shellpipe = "2>&1| tee"
  vim.o.shellredir = ">%s 2>&1"
  vim.o.shellquote = ""
  vim.o.shellxquote = '"'
end

if vim.fn.has("win32") == 1 then
  use_powershell()
end

vim.api.nvim_create_user_command("UseCmdShell", function()
  use_cmd()
  vim.notify("Shell: cmd.exe")
end, { desc = "Vaqtincha cmd.exe ga qaytish (:TSInstallSync uchun)" })

vim.api.nvim_create_user_command("UsePowerShell", function()
  if use_powershell() then
    vim.notify("Shell: " .. vim.o.shell)
  else
    vim.notify("PowerShell topilmadi", vim.log.levels.WARN)
  end
end, { desc = "PowerShell'ga qaytish" })

-- File Handling
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.hidden = true
vim.opt.confirm = true

-- Autosave bor: swap fayl keraksiz, lekin undo tarixi disk'da saqlansin
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undolevels = 1000

-- Fayl tashqarida o'zgarsa qayta o'qish.
-- CursorHold OLIB TASHLANDI: har 250ms da disk'ni tekshirish Windows'da sekin.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  command = "checktime",
})

vim.api.nvim_create_autocmd("FileChangedShell", {
  callback = function()
    if vim.fn.filereadable(vim.fn.expand("%")) == 0 then
      vim.schedule(function()
        vim.cmd("bdelete")
      end)
    end
  end,
})

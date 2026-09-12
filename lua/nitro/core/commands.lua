-- ===========================================================================
--  Foydalanuvchi buyruqlari
-- ===========================================================================

vim.api.nvim_create_user_command("MkDir", function(opts)
  local dir = opts.args
  if dir == "" then
    vim.notify("Papka yo'lini kiriting!", vim.log.levels.WARN)
    return
  end
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
    vim.notify("Papka yaratildi: " .. dir)
  else
    vim.notify("Papka allaqachon bor: " .. dir, vim.log.levels.WARN)
  end
end, { nargs = 1, complete = "dir", desc = "Papka yaratish" })

vim.api.nvim_create_user_command("CloseAllBuffers", function()
  local current_buf = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and buf ~= current_buf then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  vim.notify("Joriy fayldan boshqa hamma buffer yopildi")
end, { nargs = 0, desc = "Boshqa barcha buffer'larni yopish" })

-- toggleterm require() FUNKSIYA ICHIDA: aks holda plugin har startupda
-- yuklanib, lazy-loading buzilardi.
vim.api.nvim_create_user_command("VTerm", function(opts)
  local n = tonumber(opts.args)
  if not n or n < 1 then
    vim.notify("Terminallar soni >= 1 bo'lishi kerak", vim.log.levels.WARN)
    return
  end
  if n > 4 then
    vim.notify("Ko'pi bilan 4 ta terminal", vim.log.levels.WARN)
    return
  end

  local ok, tt = pcall(require, "toggleterm.terminal")
  if not ok then
    vim.notify("toggleterm topilmadi", vim.log.levels.ERROR)
    return
  end

  for _ = 1, n do
    tt.Terminal:new({ direction = "horizontal", size = 15, close_on_exit = false }):toggle()
  end
end, { nargs = 1, desc = "Bir nechta terminal ochish" })

-- ===========================================================================
--  :Run  --  joriy faylni kompilyatsiya qilib ishga tushiradi
--
--  Buyruqlar PowerShell sintaksisida yozilgan (options.lua ga qarang):
--    `if ($?) { ... }` -- oldingi qadam muvaffaqiyatli bo'lsagina davom etadi.
-- ===========================================================================

local function quote(s)
  return '"' .. s .. '"'
end

---@return string? cmd, string? err
local function build_run_command()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local stem = vim.fn.expand("%:t:r")
  local exe = dir .. "\\" .. stem .. ".exe"

  if ft == "cpp" then
    if vim.fn.executable("g++") ~= 1 then
      return nil, "g++ topilmadi. O'rnatish: winget install BrechtSanders.WinLibs.POSIX.UCRT"
    end
    return ("g++ -std=c++20 -O2 -Wall -Wextra %s -o %s ; if ($?) { & %s }")
        :format(quote(file), quote(exe), quote(exe))
  elseif ft == "c" then
    if vim.fn.executable("gcc") ~= 1 then
      return nil, "gcc topilmadi. O'rnatish: winget install BrechtSanders.WinLibs.POSIX.UCRT"
    end
    return ("gcc -std=c17 -O2 -Wall -Wextra %s -o %s ; if ($?) { & %s }")
        :format(quote(file), quote(exe), quote(exe))
  elseif ft == "python" then
    return ("python %s"):format(quote(file))
  elseif ft == "java" then
    return ("javac -d %s %s ; if ($?) { java -cp %s %s }")
        :format(quote(dir), quote(file), quote(dir), stem)
  elseif ft == "javascript" then
    return ("node %s"):format(quote(file))
  elseif ft == "typescript" or ft == "typescriptreact" then
    return ("npx --yes tsx %s"):format(quote(file))
  elseif ft == "rust" then
    if vim.fn.filereadable(vim.fs.joinpath(vim.fn.getcwd(), "Cargo.toml")) == 1 then
      return "cargo run"
    end
    return ("rustc %s -o %s ; if ($?) { & %s }")
        :format(quote(file), quote(exe), quote(exe))
  elseif ft == "cs" then
    return "dotnet run"
  elseif ft == "lua" then
    return ("nvim -l %s"):format(quote(file))
  elseif ft == "sh" then
    return ("bash %s"):format(quote(file))
  end

  return nil, "Bu fayl turi uchun :Run sozlanmagan -> " .. (ft ~= "" and ft or "noma'lum")
end

local runner = nil

local function run_file()
  if vim.fn.expand("%") == "" then
    vim.notify("Avval faylni saqlang", vim.log.levels.WARN)
    return
  end

  local cmd, err = build_run_command()
  if not cmd then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  vim.cmd("silent! write")

  local ok, tt = pcall(require, "toggleterm.terminal")
  if not ok then
    vim.notify("toggleterm topilmadi", vim.log.levels.ERROR)
    return
  end

  -- Oldingi run oynasini yopamiz -- terminallar to'planib ketmasin
  if runner then
    pcall(function() runner:shutdown() end)
    runner = nil
  end

  runner = tt.Terminal:new({
    cmd = cmd,
    direction = "horizontal",
    size = 15,
    close_on_exit = false, -- dastur tugagach natija ko'rinib tursin
    on_open = function(term)
      vim.keymap.set("n", "q", "<cmd>close<CR>",
        { buffer = term.bufnr, silent = true, desc = "Run oynasini yopish" })
    end,
  })
  runner:open()
end

vim.api.nvim_create_user_command("Run", run_file,
  { desc = "Joriy faylni kompilyatsiya qilib ishga tushirish" })

vim.keymap.set("n", "<leader>rr", run_file,
  { silent = true, desc = "Faylni ishga tushirish" })

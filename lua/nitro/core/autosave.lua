-- ===========================================================================
--  Autosave (debounce bilan)
--
--  ESKI xatolik: "TextChanged" har bir harf o'zgarishida faylni yozardi,
--  yozish esa BufWritePre -> LSP format (sinxron!) ni ishga tushirardi.
--  Natija: har bir harfda editor qotib qolardi.
--
--  YANGI: yozish 1.5 soniya "tinchlik"dan keyin bo'ladi va autosave paytida
--  formatlash o'tkazib yuboriladi (lsp.lua dagi nitro_autosaving flag).
-- ===========================================================================

local uv = vim.uv or vim.loop
local DEBOUNCE_MS = 1500

if vim.g.nitro_autosave == nil then
  vim.g.nitro_autosave = true
end

local timer = nil

local function stop_timer()
  if timer then
    timer:stop()
    if not timer:is_closing() then timer:close() end
    timer = nil
  end
end

local function should_save(buf)
  if vim.g.nitro_autosave == false then return false end
  if not vim.api.nvim_buf_is_valid(buf) then return false end
  if not vim.bo[buf].modified then return false end
  if not vim.bo[buf].modifiable then return false end
  if vim.bo[buf].readonly then return false end
  if vim.bo[buf].buftype ~= "" then return false end
  if vim.bo[buf].filetype == "" then return false end
  if vim.b[buf].nitro_big_file then return false end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then return false end
  -- git commit / rebase kabi maxsus fayllarni avtomatik saqlamaymiz
  if name:match("COMMIT_EDITMSG$") or name:match("git%-rebase%-todo$") then return false end
  return true
end

local function save(buf)
  if not should_save(buf) then return end
  vim.b[buf].nitro_autosaving = true
  pcall(function()
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent! write")
    end)
  end)
  vim.b[buf].nitro_autosaving = false
end

local function schedule_save(buf)
  stop_timer()
  if not should_save(buf) then return end
  timer = uv.new_timer()
  timer:start(DEBOUNCE_MS, 0, vim.schedule_wrap(function()
    stop_timer()
    -- Insert rejimda bo'lsak yozmaymiz (yozish jarayonini uzmaslik uchun)
    if vim.fn.mode():sub(1, 1) == "i" then return end
    save(buf)
  end))
end

local group = vim.api.nvim_create_augroup("NitroAutoSave", { clear = true })

-- Sekin yo'l: yozib bo'lgandan 1.5s keyin
vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
  group = group,
  callback = function(ev) schedule_save(ev.buf) end,
})

-- Tez yo'l: buffer'dan chiqqanda / oyna fokusni yo'qotganda darhol
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  group = group,
  callback = function(ev)
    stop_timer()
    save(ev.buf)
  end,
})

vim.api.nvim_create_user_command("NitroAutoSave", function(opts)
  local arg = opts.args:lower()
  if arg == "on" then
    vim.g.nitro_autosave = true
  elseif arg == "off" then
    vim.g.nitro_autosave = false
    stop_timer()
  else
    vim.g.nitro_autosave = not vim.g.nitro_autosave
    if not vim.g.nitro_autosave then stop_timer() end
  end
  vim.notify("AutoSave: " .. (vim.g.nitro_autosave and "YOQILDI" or "O'CHIRILDI"))
end, {
  nargs = "?",
  complete = function() return { "on", "off", "toggle" } end,
  desc = "Autosave'ni yoqish/o'chirish",
})

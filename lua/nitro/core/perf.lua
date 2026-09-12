-- ===========================================================================
--  Performance guard: katta fayllar va ortiqcha provider'lar
-- ===========================================================================

-- 1) Ishlatilmaydigan provider'lar. Har biri startup'da PATH'ni skanerlaydi.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

-- 2) Katta fayl chegaralari
local BIG_FILE_BYTES = 512 * 1024 -- 512 KB
local LONG_LINE_COLS = 5000       -- minify qilingan js/css uchun

local group = vim.api.nvim_create_augroup("NitroPerf", { clear = true })
local uv = vim.uv or vim.loop

local function file_size(path)
  if path == "" then return 0 end
  local ok, stat = pcall(uv.fs_stat, path)
  if ok and stat then return stat.size end
  return 0
end

-- Fayl o'qilishidan OLDIN: og'ir sozlamalarni o'chirib qo'yamiz
vim.api.nvim_create_autocmd("BufReadPre", {
  group = group,
  callback = function(ev)
    local path = vim.api.nvim_buf_get_name(ev.buf)
    if file_size(path) < BIG_FILE_BYTES then return end

    vim.b[ev.buf].nitro_big_file = true
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false
    vim.opt_local.foldenable = false
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.spell = false
    vim.opt_local.list = false
    vim.opt_local.wrap = false
    vim.opt_local.bufhidden = "unload"
  end,
})

-- Fayl o'qilgandan KEYIN: highlight / diagnostika / LSP'ni uzamiz
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(ev)
    local buf = ev.buf
    if not vim.b[buf].nitro_big_file then
      -- juda uzun qatorli (minified) fayllarni ham katta deb hisoblaymiz
      local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
      if #line < LONG_LINE_COLS then return end
      vim.b[buf].nitro_big_file = true
    end

    pcall(vim.treesitter.stop, buf)
    vim.bo[buf].syntax = "off"
    pcall(vim.diagnostic.enable, false, { bufnr = buf })

    vim.schedule(function()
      vim.notify("Katta fayl aniqlandi -> highlight/LSP o'chirildi (tezlik uchun)",
        vim.log.levels.WARN)
    end)
  end,
})

-- Katta faylga LSP ulanib qolsa, uzib yuboramiz
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    if not vim.b[ev.buf].nitro_big_file then return end
    vim.schedule(function()
      pcall(vim.lsp.buf_detach_client, ev.buf, ev.data.client_id)
    end)
  end,
})

-- 3) Qo'lda tekshirish uchun buyruq
vim.api.nvim_create_user_command("NitroPerf", function()
  local buf = vim.api.nvim_get_current_buf()
  local lines = {
    "Buffer: " .. (vim.api.nvim_buf_get_name(buf) ~= "" and vim.fs.basename(vim.api.nvim_buf_get_name(buf)) or "[No Name]"),
    "Hajmi: " .. math.floor(file_size(vim.api.nvim_buf_get_name(buf)) / 1024) .. " KB",
    "Katta fayl rejimi: " .. tostring(vim.b[buf].nitro_big_file == true),
    "Treesitter: " .. tostring(vim.treesitter.highlighter.active[buf] ~= nil),
    "Autosave: " .. tostring(vim.g.nitro_autosave ~= false),
    "Format on save: " .. tostring(vim.g.nitro_format_on_save ~= false),
  }
  local clients = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    table.insert(clients, c.name)
  end
  table.insert(lines, "LSP: " .. (#clients > 0 and table.concat(clients, ", ") or "yo'q"))
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "NitroVim Perf" })
end, { desc = "Joriy buffer performance holati" })

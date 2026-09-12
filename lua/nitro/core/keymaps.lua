-- ===========================================================================
--  Keymap'lar
--
--  MUHIM tuzatish: ilgari <leader>f (format) va <leader>ff (fayl qidirish)
--  ikkalasi ham bor edi. Shu sabab <leader>f bosilganda Neovim 400ms davomida
--  "yana harf keladimi?" deb KUTIB turardi -> sekin ishlayotgandek tuyulardi.
--  Endi <leader>f, <leader>t, <leader>g faqat PREFIX (o'zi hech nima qilmaydi).
-- ===========================================================================

local map = vim.keymap.set

-- ------------------------------------------------------------------ Fayllar
map("n", "<C-s>", "<cmd>write<CR>", { desc = "Saqlash" })
map("i", "<C-s>", "<Esc><cmd>write<CR>", { desc = "Saqlash" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Qidiruv belgisini o'chirish" })

-- ------------------------------------------------------- File Explorer
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { silent = true, desc = "Explorer ochish/yopish" })
map("n", "<leader>h", "<cmd>NvimTreeFocus<CR>", { silent = true, desc = "Explorer'ga o'tish" })

-- --------------------------------------------------------------- Terminal
-- <leader>t bitta bosishda ishlashi uchun <leader>t bilan boshlanadigan
-- BOSHQA hech qanday tugma bo'lmasligi kerak. Shu sabab test tugmalari
-- <leader>T ga (katta T) ko'chirildi -- neotest.lua ga qarang.
local function toggle_term_bottom()
  if vim.bo.filetype == "NvimTree" then
    vim.cmd("wincmd l")
  end
  vim.cmd("ToggleTerm direction=horizontal size=15")
end

map("n", "<leader>t", toggle_term_bottom, { silent = true, desc = "Terminal ochish/yopish" })

-- Terminal ICHIDA <leader> ishlatilmaydi: leader -- bu probel, va shell'da
-- "ls t" deb yozganda ham ishga tushib ketardi. Buning o'rniga:
--   <Esc><Esc>  -> normal rejim (keyin Ctrl+k bilan tahrirlovchiga)
--   <C-\>       -> terminalni yopish (toggleterm o'zi qo'yadi)
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal normal rejim" })

-- ------------------------------------------------------------- Navigatsiya
map("n", "<leader>w", "<cmd>wincmd p<CR>", { silent = true, desc = "Oldingi oynaga" })
map("n", "<leader>k", "<cmd>bnext<CR>", { silent = true, desc = "Keyingi buffer" })
map("n", "<leader>j", "<cmd>bprevious<CR>", { silent = true, desc = "Oldingi buffer" })
map("n", "<leader>q", "<cmd>bdelete<CR>", { silent = true, desc = "Buffer'ni yopish" })

-- Oynalar orasida Ctrl + h/j/k/l
map("n", "<C-h>", "<C-w>h", { desc = "Chapdagi oyna" })
map("n", "<C-j>", "<C-w>j", { desc = "Pastdagi oyna" })
map("n", "<C-k>", "<C-w>k", { desc = "Yuqoridagi oyna" })
map("n", "<C-l>", "<C-w>l", { desc = "O'ngdagi oyna" })

-- ----------------------------------------------------------------- Trouble
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Barcha xatolar" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Shu fayl xatolari" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location list" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list" })

-- -------------------------------------------------------------------- Code
map("n", "<leader>cf", function()
  vim.lsp.buf.format({ async = true })
end, { silent = true, desc = "Kodni formatlash" })

map("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbol'lar" })
map("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "LSP ma'lumot" })
map("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Code action (tuzatish taklifi)" })

-- ---------------------------------------------------------------- LSP / Saga
-- gd native: Lspsaga peek_definition dan sezilarli tez
map("n", "gd", vim.lsp.buf.definition, { silent = true, desc = "Ta'rifga o'tish" })
map("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true, desc = "Hujjat (hover)" })
map("n", "gr", "<cmd>Lspsaga finder<CR>", { silent = true, desc = "Qayerda ishlatilgan" })
map("n", "F", "<cmd>Lspsaga code_action<CR>", { silent = true, desc = "Code action" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Oldingi xato" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Keyingi xato" })

-- ------------------------------------------------------------------ Tahrir
-- Vizual rejimda qatorni yuqori/pastga surish
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Qatorni pastga" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Qatorni yuqoriga" })
-- Indent'dan keyin tanlov saqlanib qolsin
map("v", "<", "<gv", { desc = "Chapga surish" })
map("v", ">", ">gv", { desc = "O'ngga surish" })

-- ===========================================================================
--  LSP xato/ogohlantirish matnlarini o'zbekchaga tarjima qilish
--
--  Yoqish/o'chirish:  :XatoTarjima on | off | toggle
--
--  Qanday ishlaydi: diagnostika matni o'zgartirilmaydi, faqat EKRANGA
--  chiqarilayotganda tarjima qilinadi. Shuning uchun o'chirilsa darhol
--  asl inglizcha matn qaytadi.
--
--  Qoidalar taxmin bilan emas, clangd / pyright / ts_ls ning HAQIQIY
--  xabarlarini yig'ib chiqib yozilgan.
--  Diqqat: clangd har bir xabarni BOSH HARF bilan boshlaydi, ba'zi boshqa
--  serverlar kichik harf bilan. Shu sabab birinchi harf [Ee] ko'rinishida.
-- ===========================================================================

local M = {}

M.enabled = true

-- Qoidalar TARTIB bilan qo'llaniladi: aniqrog'i yuqorida turishi shart,
-- aks holda umumiy qoida uni yutib yuboradi.
-- Lua naqshlarida - ( ) . % ? [ ] belgilaridan oldin % qo'yiladi.
local rules = {
  -- ------------------------------------------------------ umumiy qo'shimchalar
  { "%(fixes available%)",                            "(avtomatik tuzatish bor)" },
  { "%(fix available%)",                              "(avtomatik tuzatish bor)" },
  { "; did you mean '(.-)'%?",                        "; balki '%1' demoqchimidingiz?" },
  { "; did you mean \"(.-)\"%?",                      "; balki \"%1\" demoqchimidingiz?" },

  -- ============================== C / C++ (clangd) ==========================

  -- '=' va '==' chalkashligi
  { "[Uu]sing the result of an assignment as a condition without parentheses",
    "shartda solishtirish '==' o'rniga o'zlashtirish '=' ishlatilgan" },
  { "[Pp]lace parentheses around the assignment to silence this warning",
    "ogohlantirishni o'chirish uchun o'zlashtirishni qavsga oling" },
  { "[Uu]se '==' to turn this assignment into an equality comparison",
    "solishtirish uchun '=' ni '==' ga o'zgartiring" },

  -- ortiqcha #include
  { "[Ii]ncluded header (.-) is not used directly",
    "'%1' ulangan, lekin bu faylda ishlatilmayapti" },

  -- yetishmayotgan belgilar
  { "[Ee]xpected ';' after expression",               "bu yerda ';' qo'yilmagan" },
  { "[Ee]xpected ';' after return statement",         "return dan keyin ';' qo'yilmagan" },
  { "[Ee]xpected ';' after struct",                   "struct dan keyin ';' qo'yilmagan" },
  { "[Ee]xpected ';' at end of declaration",          "e'lon oxirida ';' qo'yilmagan" },
  { "[Ee]xpected expression",                         "bu yerda ifoda kutilgan" },
  { "[Ee]xpected parameter name",                     "parametr nomi yozilmagan" },
  { "[Ee]xpected unqualified%-id",                    "bu yerda nom kutilgan" },
  { "[Ee]xpected identifier",                         "bu yerda nom kutilgan" },
  -- "Expected 1 arguments, but got 0." -- umumiy qoidalardan OLDIN turishi kerak
  { "[Ee]xpected (%d+) arguments?, but got (%d+)",    "%1 ta argument kerak, %2 ta berildi" },
  { '[Ee]xpected "(.-)"',                             'bu yerda "%1" kutilgan' },
  { "[Ee]xpected '(.-)'",                             "'%1' yetishmayapti" },

  -- nom / tur topilmadi
  { "[Uu]se of undeclared identifier '(.-)'",
    "'%1' e'lon qilinmagan (nomi xato yoki e'lon qilishni unutdingiz)" },
  { "[Uu]nknown type name '(.-)'",                    "'%1' degan tur mavjud emas" },
  { "[Nn]o template named '(.-)'",                    "'%1' degan shablon topilmadi" },
  { "[Nn]o member named '(.-)' in '(.-)'",            "'%2' ichida '%1' degan a'zo yo'q" },
  { "[Nn]o matching function for call to '(.-)'",
    "'%1' funksiyasini bunday argumentlar bilan chaqirib bo'lmaydi" },
  { "'(.-)' file not found",                          "'%1' fayli topilmadi" },

  -- return
  { "[Nn]on%-void function does not return a value",
    "funksiya qiymat qaytarishi kerak, lekin return yo'q" },
  { "[Cc]ontrol reaches end of non%-void function",
    "funksiya qiymat qaytarmayapti (return yo'q)" },

  -- turlar mos kelmasligi
  { "[Cc]annot initialize a variable of type '(.-)' with an [lr]value of type '(.-)'",
    "'%1' turidagi o'zgaruvchiga '%2' turidagi qiymat berib bo'lmaydi" },
  { "[Cc]annot initialize return object of type '(.-)' with an [lr]value of type '(.-)'",
    "funksiya '%1' qaytarishi kerak, siz esa '%2' qaytaryapsiz" },
  { "[Cc]annot assign to variable '(.-)' with const%-qualified type '(.-)'",
    "'%1' o'zgarmas (const) -- unga yangi qiymat berib bo'lmaydi" },
  { "[Aa]ssigning to '(.-)' from incompatible type '(.-)'",
    "'%2' turidagi qiymatni '%1' ga berib bo'lmaydi" },
  { "[Ii]mplicit conversion from '(.-)' to '(.-)' changes value from (%-?%d+) to (%-?%d+)",
    "'%1' dan '%2' ga o'tkazishda qiymat buzildi: %3 o'rniga %4" },
  { "[Cc]omparison of integers of different signs",
    "ishorali va ishorasiz sonlar solishtirilyapti" },

  -- massiv / mantiqiy xatolar
  { "[Aa]rray index (%d+) is past the end of the array %(that has type '(.-)'%)",
    "massiv chegarasidan chiqildi: %1-indeks mavjud emas (massiv turi '%2')" },
  { "[Mm]ulti%-character character constant",
    "char ichida faqat bitta belgi bo'lishi mumkin" },
  { "[Dd]uplicate case value '(.-)'",                 "'%1' case qiymati takrorlangan" },
  { "[Ff]or loop has empty body",                     "for sikli tanasi bo'sh (ortiqcha ';' bo'lishi mumkin)" },
  { "[Ww]hile loop has empty body",                   "while sikli tanasi bo'sh (ortiqcha ';' bo'lishi mumkin)" },
  { "[Ii]f statement has empty body",                 "if tanasi bo'sh (ortiqcha ';' bo'lishi mumkin)" },
  { "[Rr]edefinition of '(.-)'",                      "'%1' qayta e'lon qilingan" },
  { "[Vv]ariable '(.-)' is uninitialized when used here",
    "'%1' o'zgaruvchisiga hali qiymat berilmagan" },
  { "[Uu]nused variable '(.-)'",                      "'%1' o'zgaruvchisi ishlatilmagan" },
  { "[Ee]xtra ';'",                                   "ortiqcha ';'" },
  { "[Dd]eclaration does not declare anything",       "bu e'lon hech narsani e'lon qilmayapti" },
  { "[Dd]ivision by zero",                            "nolga bo'linish" },

  -- ================================ Python ==================================
  { '"(.-)" is not defined',                          '"%1" aniqlanmagan' },
  { 'Import "(.-)" could not be resolved',            '"%1" moduli topilmadi' },
  { '"(.-)" is not accessed',                         '"%1" ishlatilmayapti' },
  { 'Type "(.-)" is not assignable to declared type "(.-)"',
    "'%1' turini e'lon qilingan '%2' turiga berib bo'lmaydi" },
  { "[Ee]xpected indented block",                     "bu yerda ichkariga surilgan (indent) blok kutilgan" },
  { "[Ss]tatements must be separated by newlines or semicolons",
    "har bir amal alohida qatorda bo'lishi kerak" },
  { '"%(" was not closed',                            "ochilgan '(' yopilmagan" },
  { '"%[" was not closed',                            "ochilgan '[' yopilmagan" },
  { '"{" was not closed',                             "ochilgan '{' yopilmagan" },
  { "[Uu]ndefined name `(.-)`",                       "noma'lum nom: `%1`" },
  { "[Ii]mported but unused",                         "import qilingan, lekin ishlatilmagan" },
  { "[Uu]nindent not expected",                       "kutilmagan indent (bo'sh joy) o'zgarishi" },
  { "Position%-only parameter separator not allowed as first parameter",
    "'/' belgisi birinchi parametr bo'la olmaydi" },

  -- ========================= TypeScript / React =============================
  { "[Cc]annot find name '(.-)'",                     "'%1' topilmadi" },
  { "[Cc]annot find module '(.-)'",                   "'%1' moduli topilmadi" },
  { "[Pp]roperty '(.-)' does not exist on type '(.-)'",
    "'%2' turida '%1' degan xossa yo'q" },
  { "[Tt]ype '(.-)' is not assignable to type '(.-)'",
    "'%1' turini '%2' turiga berib bo'lmaydi" },
  { "'(.-)' is declared but its value is never read",
    "'%1' e'lon qilingan, lekin hech qayerda ishlatilmagan" },
  { "[Oo]bject is possibly 'null'",                   "bu qiymat 'null' bo'lishi mumkin" },
  { "[Oo]bject is possibly 'undefined'",              "bu qiymat 'undefined' bo'lishi mumkin" },
  { "[Aa]ll imports in import declaration are unused",
    "bu qatordagi import'lar ishlatilmayapti" },

  -- ================================= Java ===================================
  { 'Syntax error, insert "(.-)" to complete',        'sintaksis xatosi: "%1" qo\'shish kerak' },
  { "[Cc]annot be resolved to a type",                "bunday tur topilmadi" },
  { "[Cc]annot be resolved to a variable",            "bunday o'zgaruvchi topilmadi" },
  { "The value of the local variable (.-) is not used",
    "'%1' lokal o'zgaruvchisi ishlatilmagan" },
  { "[Tt]he method (.-) is undefined for the type (.-)",
    "'%2' turida '%1' metodi yo'q" },
}

---@param msg string
---@return string
function M.translate(msg)
  if not M.enabled or type(msg) ~= "string" then
    return msg
  end
  local out = msg
  for _, rule in ipairs(rules) do
    local ok, res = pcall(string.gsub, out, rule[1], rule[2])
    if ok then
      out = res
    end
  end
  return out
end

--- tiny-inline-diagnostic va vim.diagnostic.config uchun format funksiyasi
---@param diagnostic table
---@return string
function M.format(diagnostic)
  return M.translate(diagnostic.message)
end

vim.api.nvim_create_user_command("XatoTarjima", function(opts)
  local arg = opts.args:lower()
  if arg == "on" then
    M.enabled = true
  elseif arg == "off" then
    M.enabled = false
  else
    M.enabled = not M.enabled
  end
  vim.diagnostic.show()
  vim.cmd("redraw!")
  vim.notify("Xato matnlari: " .. (M.enabled and "O'ZBEKCHA" or "inglizcha"))
end, {
  nargs = "?",
  complete = function() return { "on", "off", "toggle" } end,
  desc = "LSP xato matnlarini o'zbekchaga tarjima qilishni yoqish/o'chirish",
})

-- Tarjima qilinmagan xabarlarni topish uchun (yangi qoida yozish kerak bo'lsa)
vim.api.nvim_create_user_command("XatoAsl", function()
  local ds = vim.diagnostic.get(0)
  if #ds == 0 then
    vim.notify("Bu faylda xato yo'q")
    return
  end
  local lines = {}
  for _, d in ipairs(ds) do
    table.insert(lines, (d.lnum + 1) .. "-qator: " .. d.message:gsub("\n", " "))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO,
    { title = "Asl (inglizcha) xabarlar" })
end, { desc = "Joriy fayldagi xatolarning asl inglizcha matnini ko'rsatish" })

return M

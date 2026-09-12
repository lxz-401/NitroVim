-- ===========================================================================
--  Treesitter (sintaksis highlight)
--
--  ESKI xatolik: plugin "main" branch'da edi, config esa "master" API sini
--  (ensure_installed / highlight / indent) ishlatardi. "main" bu kalitlarni
--  umuman o'qimaydi -> hech qanday parser o'rnatilmagan, highlight o'chiq,
--  Neovim eski sekin regex-syntax'ga qaytgan edi.
--  Endi plugin "master" branch'da (plugins.lua ga qarang) va bu API ishlaydi.
-- ===========================================================================

local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
  vim.notify("nvim-treesitter topilmadi. :Lazy sync ni ishga tushiring.", vim.log.levels.WARN)
  return
end

-- Bir vaqtda faqat BITTA parser kompilyatsiya qilinsin.
--
-- Bu mashinada yagona C kompilyatori -- zig. Bir nechta `zig cc` bir vaqtda
-- ishga tushsa, ular umumiy zig keshi qulfida bir-birini kutib qotib qoladi:
-- jarayonlar tirik qoladi, lekin o'rnatish hech qachon tugamaydi va
-- yarim yuklangan `tree-sitter-*` papkalari keyingi urinishlarni ham bloklaydi.
-- max_jobs = 1 sekinroq, lekin ishonchli.
--
-- Agar biror parser baribir o'rnatilmasa: `:TSInstall <til>` ni bittalab bajaring.
local ok_install, install = pcall(require, "nvim-treesitter.install")
if ok_install then
  install.max_jobs = 1
end

configs.setup({
  ensure_installed = {
    -- asosiy
    "lua", "vim", "vimdoc", "query", "regex",
    -- web / react
    "javascript", "typescript", "tsx", "html", "css", "scss", "json", "jsonc",
    -- python
    "python", "toml",
    -- java
    "java",
    -- boshqalar
    "c", "cpp", "c_sharp", "rust", "bash", "xml", "yaml",
    "markdown", "markdown_inline", "gitignore", "dockerfile",
  },

  -- false: parser'lar fon'da avtomatik kompilyatsiya qilinmaydi.
  -- true bo'lsa notanish fayl ochilganda Neovim compile'ni kutib qotib qoladi.
  auto_install = false,
  sync_install = false,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
    -- Katta fayllarda highlight'ni o'chiramiz (perf.lua belgilaydi)
    disable = function(_, buf)
      if vim.b[buf] and vim.b[buf].nitro_big_file then
        return true
      end
      local ok_stat, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(buf))
      return ok_stat and stats and stats.size > 512 * 1024
    end,
  },

  -- Treesitter indent Python va YAML da noto'g'ri ishlaydi -> o'chirilgan
  indent = {
    enable = true,
    disable = { "python", "yaml" },
  },
})

-- ===========================================================================
--  Neovim 0.12+ Moslashuvi: Treesitter Predikatlari va Direktivlari
--  Neovim 0.12 da iter_matches match[id] ni bitta node emas, { node1, ... } jadval
--  qilib qaytaradi. nvim-treesitter dagi eski direktivlar shuning uchun
--  "attempt to call method 'range' (a nil value)" xatosini beradi.
-- ===========================================================================
local function unwrap_ts_node(node)
  if type(node) == "table" and not node.range then
    return node[#node] or node[1]
  end
  return node
end

local q = vim.treesitter.query
if q and q.add_directive then
  -- set-lang-from-info-string! (Markdown codeblocks highlight uchun)
  q.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
    local node = unwrap_ts_node(match[pred[2]])
    if not node then return end
    local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
    if ok and text then
      local lang = text:lower():match("^%s*([%w_%-]+)")
      if lang then
        metadata["injection.language"] = lang
      end
    end
  end, { force = true, all = false })

  -- downcase!
  q.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
    local id = pred[2]
    local node = unwrap_ts_node(match[id])
    if not node then return end
    local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr, { metadata = metadata[id] })
    if ok and text then
      metadata[id] = metadata[id] or {}
      metadata[id].text = text:lower()
    end
  end, { force = true, all = false })

  -- set-lang-from-mimetype! (HTML script tags)
  q.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
    local node = unwrap_ts_node(match[pred[2]])
    if not node then return end
    local ok, type_attr = pcall(vim.treesitter.get_node_text, node, bufnr)
    if ok and type_attr then
      local parts = vim.split(type_attr, "/", {})
      metadata["injection.language"] = parts[#parts]
    end
  end, { force = true, all = false })
end


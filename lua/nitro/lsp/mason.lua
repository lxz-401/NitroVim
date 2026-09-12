-- ===========================================================================
--  Mason: LSP serverlarni o'rnatish
-- ===========================================================================

require("mason").setup({
  registries = {
    "github:Crashdummyy/mason-registry",
    "github:mason-org/mason-registry",
  },
  max_concurrent_installers = 4,
  ui = { border = "rounded" },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "ts_ls",
    "eslint",
    "html",
    "cssls",
    "tailwindcss",
    "emmet_language_server",
    "jsonls",
    "pyright",
    "jdtls",
    "clangd",
  },
  -- false: serverlarni faqat lsp.lua dagi ro'yxat yoqadi.
  -- true bo'lsa mason har qanday o'rnatilgan serverni ham yoqib yuboradi.
  automatic_enable = false,
})

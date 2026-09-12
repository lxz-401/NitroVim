-- ===========================================================================
--  LSP sozlamalari
-- ===========================================================================

require("nitro.lsp.mason")

-- LSP log'ini o'chiramiz: har bir server xabari disk'ga yozilardi (Windows'da sekin).
-- Debug kerak bo'lsa: :lua vim.lsp.log.set_level("debug")
pcall(function()
  vim.lsp.log.set_level("off")
end)

if vim.g.nitro_format_on_save == nil then
  vim.g.nitro_format_on_save = true
end

-- ---------------------------------------------------------------------------
-- Capabilities
-- ---------------------------------------------------------------------------
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- MUHIM (Windows'dagi eng katta sekinlik sababi):
-- LSP serverlar node_modules / .venv / target ichidagi o'n minglab faylni
-- "watch" qilishni so'raydi. Neovim ularni kuzatib, har o'zgarishda qotib qoladi.
capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.didChangeWatchedFiles = {
  dynamicRegistration = false,
  relativePatternSupport = false,
}

vim.lsp.config("*", {
  capabilities = capabilities,
})

-- ---------------------------------------------------------------------------
-- Til bo'yicha sozlash (og'ir serverlarni jilovlaymiz)
-- ---------------------------------------------------------------------------

-- Python: butun loyihani emas, faqat ochiq fayllarni tahlil qiladi
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "basic",
        useLibraryCodeForTypes = true,
        autoSearchPaths = true,
        autoImportCompletions = true,
      },
    },
  },
})

-- TypeScript / React: inlay hint'lar o'chiq, xotira chegarasi kattaroq
vim.lsp.config("ts_ls", {
  init_options = {
    maxTsServerMemory = 4096,
  },
  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = "never" },
      inlayHints = {
        includeInlayParameterNameHints = "none",
        includeInlayVariableTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = false,
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "never" },
      inlayHints = {
        includeInlayParameterNameHints = "none",
        includeInlayVariableTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = false,
      },
    },
  },
})

-- ESLint: React loyihalarda eng sekin server. Har harfda emas, saqlaganda ishlaydi.
vim.lsp.config("eslint", {
  settings = {
    run = "onSave",
    workingDirectories = { mode = "auto" },
    useESLintClass = true,
  },
})

-- Tailwind: keraksiz papkalarni skanerlamasin
vim.lsp.config("tailwindcss", {
  settings = {
    tailwindCSS = {
      files = {
        exclude = {
          "**/.git/**", "**/node_modules/**", "**/.next/**",
          "**/dist/**", "**/build/**", "**/.venv/**",
        },
      },
    },
  },
})

-- Java
vim.lsp.config("jdtls", {
  settings = {
    java = {
      configuration = { updateBuildConfiguration = "interactive" },
      maxConcurrentBuilds = 1,
      import = {
        gradle = { enabled = true },
        maven = { enabled = true },
      },
      references = { includeDecompiledSources = false },
      implementationsCodeLens = { enabled = false },
      referencesCodeLens = { enabled = false },
      signatureHelp = { enabled = true },
      eclipse = { downloadSources = false },
    },
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { globals = { "vim" } },
    },
  },
})

-- ---------------------------------------------------------------------------
-- Serverlarni yoqish (faqat haqiqatan o'rnatilganlarini)
-- ---------------------------------------------------------------------------
local servers = {
  lua_ls                = "lua-language-server",
  ts_ls                 = "typescript-language-server",
  eslint                = "vscode-eslint-language-server",
  html                  = "vscode-html-language-server",
  cssls                 = "vscode-css-language-server",
  tailwindcss           = "tailwindcss-language-server",
  emmet_language_server = "emmet-language-server",
  jsonls                = "vscode-json-language-server",
  pyright               = "pyright-langserver",
  ruff                  = "ruff", -- tez linter + formatter (Python)
  jdtls                 = "jdtls",
  csharp_ls             = "csharp-ls",
  rust_analyzer         = "rust-analyzer",
  clangd                = "clangd",
}

local enabled = {}
for server, exe in pairs(servers) do
  if vim.fn.executable(exe) == 1 then
    table.insert(enabled, server)
  end
end

if #enabled > 0 then
  vim.lsp.enable(enabled)
end

vim.api.nvim_create_user_command("NitroLspInfo", function()
  local missing = {}
  for server, exe in pairs(servers) do
    if vim.fn.executable(exe) ~= 1 then
      table.insert(missing, server .. " (" .. exe .. ")")
    end
  end
  local on = vim.deepcopy(enabled)
  table.sort(on)
  table.sort(missing)
  vim.notify(
    "Yoqilgan:\n  " .. (#on > 0 and table.concat(on, "\n  ") or "-") ..
    "\n\nO'rnatilmagan (:Mason bilan o'rnating):\n  " ..
    (#missing > 0 and table.concat(missing, "\n  ") or "-"),
    vim.log.levels.INFO, { title = "NitroVim LSP" })
end, { desc = "Qaysi LSP serverlar bor/yo'qligini ko'rsatadi" })

-- ---------------------------------------------------------------------------
-- Keymap'lar (Lspsaga bilan to'qnashmaydiganlari; qolgani keymaps.lua da)
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("NitroLspAttach", { clear = true }),
  callback = function(args)
    local opts = { noremap = true, silent = true, buffer = args.buf }

    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    -- Eslatma: <C-k> ni ishlatmaymiz -- u LuaSnip'da band (snippets.lua)
    vim.keymap.set("n", "<leader>K", vim.lsp.buf.signature_help, opts)
  end,
})

-- ---------------------------------------------------------------------------
-- Format on save
--
--  ESKI xatolik: pattern="*" + async=false -> har bir yozishda (autosave ham!)
--  editor LSP javobini KUTIB turardi. Katta loyihada bu = qotib qolish.
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("NitroFormat", { clear = true }),
  callback = function(ev)
    if vim.g.nitro_format_on_save == false then return end
    if vim.b[ev.buf].nitro_autosaving then return end -- autosave'da formatlamaymiz
    if vim.b[ev.buf].nitro_big_file then return end
    if vim.b[ev.buf].nitro_no_format then return end

    local clients = vim.lsp.get_clients({ bufnr = ev.buf, method = "textDocument/formatting" })
    if #clients == 0 then return end

    pcall(vim.lsp.buf.format, {
      bufnr = ev.buf,
      async = false,
      timeout_ms = 1000, -- 1 soniyadan ko'p kutmaydi
    })
  end,
})

vim.api.nvim_create_user_command("NitroFormatToggle", function()
  vim.g.nitro_format_on_save = not vim.g.nitro_format_on_save
  vim.notify("Format on save: " .. (vim.g.nitro_format_on_save and "YOQILDI" or "O'CHIRILDI"))
end, { desc = "Saqlaganda avto-formatlashni yoqish/o'chirish" })

-- Joriy buffer uchun formatlashni o'chirish
vim.api.nvim_create_user_command("NitroNoFormat", function()
  vim.b.nitro_no_format = not vim.b.nitro_no_format
  vim.notify("Bu buffer uchun format: " .. (vim.b.nitro_no_format and "O'CHIRILDI" or "YOQILDI"))
end, { desc = "Joriy buffer uchun avto-formatlashni o'chirish" })

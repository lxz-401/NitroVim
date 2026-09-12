local uz = require("nitro.core.diagnostics_uz")

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2, format = uz.format },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.HINT]  = " 󰋗",
      [vim.diagnostic.severity.INFO]  = " ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.HINT]  = "",
      [vim.diagnostic.severity.INFO]  = "",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    focusable = true,
    max_width = 80,
    wrap = true,
    source = "always",
    header = "",
    prefix = "",
    format = uz.format,
  },
})

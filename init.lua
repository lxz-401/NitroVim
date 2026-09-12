-- ===========================================================================
--  NitroVim
-- ===========================================================================

-- Lua modul kesh (bytecode cache). Startup'ni 20-30% tezlashtiradi.
if vim.loader then
  vim.loader.enable()
end

require("nitro.core.options")
require("nitro.core.perf")
require("nitro.core.keymaps")
require("nitro.core.filetypes")
require("nitro.core.diagnostics")

require("nitro.plugins.plugins")

require("nitro.core.commands")
require("nitro.core.cmp")
require("nitro.core.autosave")
require("nitro.core.telescope")
require("nitro.core.treesitter")

require("nitro.ui.colorschemes")
require("nitro.ui.tabs")
require("nitro.ui.notify")
require("nitro.ui.transparent")
require("nitro.ui.statusline")
require("nitro.ui.nvimtree")

require("nitro.lsp.lsp")

require("nitro.snippets.snippets")
require("nitro.snippets.custom.custom_snippets")

require("nitro.modules.nitrolearn")

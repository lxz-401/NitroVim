-- Local colorscheme: no plugin download or desktop process is needed.
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.g.colors_name = "nothingos"
package.loaded["nothingos.theme"] = nil
require("nothingos.theme").apply()

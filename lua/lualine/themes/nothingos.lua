local p = require("nothingos.theme").palette
local function mode(color)
  return {
    a = { fg = p.bg, bg = color, gui = "bold" },
    b = { fg = p.fg, bg = p.raised }, c = { fg = p.muted, bg = p.panel },
  }
end
return {
  normal = mode(p.mint), insert = mode(p.blue), visual = mode(p.purple),
  replace = mode(p.red), command = mode(p.yellow), terminal = mode(p.cyan),
  inactive = {
    a = { fg = p.subtle, bg = p.panel }, b = { fg = p.subtle, bg = p.panel },
    c = { fg = p.subtle, bg = p.bg },
  },
}

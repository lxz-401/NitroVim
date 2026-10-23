local M = {}
M.palette = {
  bg = "#111111", panel = "#191919", raised = "#242424", border = "#404040",
  fg = "#f5f5f5", muted = "#ababab", subtle = "#858585", mint = "#45ffbc",
  selection = "#245c49", blue = "#82aaff", cyan = "#7fdbca", purple = "#c792ea",
  red = "#ff6b6b", yellow = "#e8cd7e",
}

function M.apply()
  local p = M.palette
  local groups = {
    Normal = { fg = p.fg, bg = p.bg }, NormalNC = { fg = p.fg, bg = p.bg },
    NormalFloat = { fg = p.fg, bg = p.raised }, FloatBorder = { fg = p.border, bg = p.raised },
    FloatTitle = { fg = p.mint, bg = p.raised, bold = true },
    EndOfBuffer = { fg = p.bg }, NonText = { fg = p.border }, Whitespace = { fg = p.border },
    SpecialKey = { fg = p.subtle }, Conceal = { fg = p.subtle },
    Cursor = { fg = p.bg, bg = p.mint }, CursorLine = { bg = p.panel },
    CursorColumn = { bg = p.panel }, ColorColumn = { bg = p.panel },
    LineNr = { fg = p.subtle, bg = p.bg }, CursorLineNr = { fg = p.mint, bold = true },
    SignColumn = { bg = p.bg }, FoldColumn = { fg = p.subtle, bg = p.bg },
    Folded = { fg = p.muted, bg = p.panel }, WinSeparator = { fg = p.border },
    Visual = { bg = p.selection }, Search = { fg = p.bg, bg = p.yellow },
    IncSearch = { fg = p.bg, bg = p.mint }, CurSearch = { fg = p.bg, bg = p.mint, bold = true },
    MatchParen = { fg = p.mint, bg = p.selection, bold = true },
    Pmenu = { fg = p.fg, bg = p.raised }, PmenuSel = { fg = p.bg, bg = p.mint, bold = true },
    PmenuSbar = { bg = p.panel }, PmenuThumb = { bg = p.border },
    StatusLine = { fg = p.fg, bg = p.raised }, StatusLineNC = { fg = p.subtle, bg = p.panel },
    TabLine = { fg = p.muted, bg = p.panel }, TabLineFill = { bg = p.bg },
    TabLineSel = { fg = p.mint, bg = p.raised, bold = true },
    WinBar = { fg = p.fg, bg = p.bg }, WinBarNC = { fg = p.subtle, bg = p.bg },
    MsgArea = { fg = p.fg, bg = p.bg }, ModeMsg = { fg = p.mint, bold = true },
    MoreMsg = { fg = p.mint }, Question = { fg = p.mint }, Title = { fg = p.mint, bold = true },
    ErrorMsg = { fg = p.red }, WarningMsg = { fg = p.yellow }, Directory = { fg = p.mint },
    Comment = { fg = p.subtle, italic = true }, Constant = { fg = p.yellow },
    String = { fg = p.cyan }, Character = { fg = p.cyan }, Number = { fg = p.yellow },
    Boolean = { fg = p.yellow }, Float = { fg = p.yellow }, Identifier = { fg = p.fg },
    Function = { fg = p.mint }, Statement = { fg = p.purple }, Operator = { fg = p.muted },
    Keyword = { fg = p.purple }, PreProc = { fg = p.blue }, Type = { fg = p.blue },
    Special = { fg = p.cyan }, Delimiter = { fg = p.muted },
    Underlined = { fg = p.blue, underline = true }, Ignore = { fg = p.subtle },
    Error = { fg = p.red }, Todo = { fg = p.bg, bg = p.yellow, bold = true },
    DiffAdd = { bg = "#18372b" }, DiffChange = { bg = "#1d2b3e" },
    DiffDelete = { fg = p.red, bg = "#3d2020" }, DiffText = { bg = "#2c4260" },
    NvimTreeNormal = { fg = p.fg, bg = p.panel }, NvimTreeNormalNC = { fg = p.fg, bg = p.panel },
    NvimTreeEndOfBuffer = { fg = p.panel, bg = p.panel }, NvimTreeWinSeparator = { fg = p.border },
    NvimTreeCursorLine = { bg = p.selection }, NvimTreeFolderName = { fg = p.fg },
    NvimTreeOpenedFolderName = { fg = p.mint, bold = true }, NvimTreeFolderIcon = { fg = p.mint },
    NvimTreeRootFolder = { fg = p.mint, bold = true }, NvimTreeIndentMarker = { fg = p.border },
    NvimTreeGitNew = { fg = p.mint }, NvimTreeGitDirty = { fg = p.yellow },
    NvimTreeGitDeleted = { fg = p.red }, NvimTreeLiveFilterPrefix = { fg = p.mint, bg = p.raised },
    NvimTreeLiveFilterValue = { fg = p.fg, bg = p.raised },
    TelescopeNormal = { fg = p.fg, bg = p.panel }, TelescopeBorder = { fg = p.border, bg = p.panel },
    TelescopePromptNormal = { fg = p.fg, bg = p.raised },
    TelescopePromptBorder = { fg = p.mint, bg = p.raised },
    TelescopePromptPrefix = { fg = p.mint, bg = p.raised },
    TelescopeSelection = { bg = p.selection, bold = true }, TelescopeSelectionCaret = { fg = p.mint },
    TelescopeMatching = { fg = p.mint, bold = true },
    BufferLineFill = { bg = p.bg }, BufferLineBackground = { fg = p.muted, bg = p.panel },
    BufferLineBufferSelected = { fg = p.mint, bg = p.raised, bold = true, italic = false },
    BufferLineBufferVisible = { fg = p.fg, bg = p.panel },
    BufferLineIndicatorSelected = { fg = p.mint, bg = p.raised },
    BufferLineModifiedSelected = { fg = p.yellow, bg = p.raised },
    BufferLineOffset = { fg = p.muted, bg = p.panel },
    DashboardHeader = { fg = p.mint }, DashboardCenter = { fg = p.fg },
    DashboardShortCut = { fg = p.mint }, DashboardFooter = { fg = p.subtle },
  }
  local links = {
    ["@variable"] = "Identifier", ["@variable.builtin"] = "Special",
    ["@variable.parameter"] = "Identifier", ["@property"] = "Identifier",
    ["@string"] = "String", ["@string.escape"] = "Special", ["@number"] = "Number",
    ["@boolean"] = "Boolean", ["@constant"] = "Constant", ["@constant.builtin"] = "Constant",
    ["@function"] = "Function", ["@function.call"] = "Function", ["@function.builtin"] = "Special",
    ["@function.method"] = "Function", ["@function.method.call"] = "Function",
    ["@keyword"] = "Keyword", ["@operator"] = "Operator", ["@type"] = "Type",
    ["@type.builtin"] = "Type", ["@tag"] = "Type", ["@tag.attribute"] = "Identifier",
    ["@comment"] = "Comment", ["@punctuation"] = "Delimiter",
    ["@markup.heading"] = "Title", ["@markup.link"] = "Underlined",
    ["@markup.raw"] = "String", ["@lsp.type.variable"] = "Identifier",
    ["@lsp.type.parameter"] = "Identifier", ["@lsp.type.property"] = "Identifier",
    TelescopeTitle = "FloatTitle", TelescopePromptTitle = "FloatTitle",
    TelescopeResultsNormal = "TelescopeNormal", TelescopeResultsBorder = "TelescopeBorder",
    TelescopePreviewNormal = "TelescopeNormal", TelescopePreviewBorder = "TelescopeBorder",
    NvimTreeVertSplit = "NvimTreeWinSeparator", NvimTreeLiveFilterBorder = "FloatBorder",
    GitSignsAdd = "DiagnosticOk", GitSignsChange = "DiagnosticWarn", GitSignsDelete = "DiagnosticError",
  }
  local severities = { Error = p.red, Warn = p.yellow, Info = p.blue, Hint = p.cyan, Ok = p.mint }
  for name, color in pairs(severities) do
    groups["Diagnostic" .. name] = { fg = color }
    groups["DiagnosticSign" .. name] = { fg = color, bg = p.bg }
    groups["DiagnosticVirtualText" .. name] = { fg = color, bg = p.panel }
    groups["DiagnosticUnderline" .. name] = { sp = color, undercurl = true }
  end
  for name, color in pairs({ ERROR = p.red, WARN = p.yellow, INFO = p.mint, DEBUG = p.subtle, TRACE = p.purple }) do
    groups["Notify" .. name .. "Border"] = { fg = p.border, bg = p.raised }
    groups["Notify" .. name .. "Title"] = { fg = color, bg = p.raised }
    groups["Notify" .. name .. "Icon"] = { fg = color, bg = p.raised }
    groups["Notify" .. name .. "Body"] = { fg = p.fg, bg = p.raised }
  end
  for name, value in pairs(groups) do vim.api.nvim_set_hl(0, name, value) end
  for name, target in pairs(links) do vim.api.nvim_set_hl(0, name, { link = target }) end
  local terminal = { p.raised, p.red, p.mint, p.yellow, p.blue, p.purple, p.cyan, "#e6e6e6",
    p.subtle, "#ff9090", "#71ffcd", "#ffe69a", "#a8c7ff", "#e1b5ff", "#a3f3e6", "#ffffff" }
  for i, color in ipairs(terminal) do vim.g["terminal_color_" .. (i - 1)] = color end
end

return M

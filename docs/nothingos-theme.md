# NothingOS theme

NothingOS is the default theme (`theme.json`). Existing themes remain available
through `:ThemeSwitch`; choosing one saves it for the next launch. The previous
default was `onedark (darker)`.

The colorscheme is local and requires no additional plugin download:

- `colors/nothingos.lua`: colorscheme entry point.
- `lua/nothingos/theme.lua`: palette, syntax, Tree-sitter, LSP and UI highlights.
- `lua/lualine/themes/nothingos.lua`: matching statusline; loaded by `theme = 'auto'`.

The palette matches the [NothingOS desktop configuration](https://github.com/lxz-401/nothingos-gnome-manjaro):
`#111111` background, charcoal panels, white text and `#45ffbc` mint accents.
Edit the palette in `lua/nothingos/theme.lua` and reload with
`:colorscheme nothingos`. Syntax and diagnostics retain distinct colors.

## Transparency and fonts

Existing saved transparency preferences are preserved. Use `:TransparentDisable`
for solid editor/panel backgrounds, or `:TransparentEnable` to reveal the terminal
background. Disabling transparency restores colors through the colorscheme.
Terminal opacity and font family are controlled by the terminal emulator.

## Verification

Verified on Neovim 0.12.6, both without plugins and with the installed NitroVim
plugin set: startup, theme switching, opaque/transparent backgrounds, mint active
buffer/statusline and opening nvim-tree/Telescope. The theme adds no background
processes, timers or plugin dependencies.

The installed nvim-tree version leaves a suppressed `E216: No such group or
event: FileExplorer *` in `v:errmsg` while removing netrw autocommands. The
previous OneDark configuration reproduces it too; theme reload itself leaves
`v:errmsg` empty. The explorer continues to work.

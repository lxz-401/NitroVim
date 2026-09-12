![Banner](https://github.com/user-attachments/assets/ac4a7952-4876-423f-a9bc-119891b62b42)

<h3 align="center">A modern, blazing-fast Neovim distribution designed for an exceptional development experience.</h3>

<p align="center">
  <a href="https://github.com/lxz-401/NitroVim/stargazers">
    <img src="https://img.shields.io/github/stars/lxz-401/NitroVim?style=for-the-badge&color=yellow" alt="Stars" />
  </a>
  <a href="https://github.com/lxz-401/NitroVim/network/members">
    <img src="https://img.shields.io/github/forks/lxz-401/NitroVim?style=for-the-badge&color=blue" alt="Forks" />
  </a>
  <a href="https://github.com/lxz-401/NitroVim/issues">
    <img src="https://img.shields.io/github/issues/lxz-401/NitroVim?style=for-the-badge&color=orange" alt="Issues" />
  </a>
  <a href="https://github.com/lxz-401/NitroVim/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/lxz-401/NitroVim?style=for-the-badge&color=success" alt="License" />
  </a>
  <a href="https://github.com/lxz-401/NitroVim">
    <img src="https://img.shields.io/github/repo-size/lxz-401/NitroVim?style=for-the-badge&color=red" alt="Repo Size" />
  </a>
</p>

> **This is a fork of [NitroVim/NitroVim](https://github.com/NitroVim/NitroVim)**, tuned for
> Python / Java / React work on Windows. See [What's different in this fork](#whats-different-in-this-fork).

## What's different in this fork

The upstream config froze on almost every keystroke in a large project. The cause was a loop
between two settings: autosave fired on `TextChanged`, so every character wrote the file, and
`BufWritePre` ran `vim.lsp.buf.format({ async = false })`, which blocks Neovim until the language
server replies.

That, and a few other things, are fixed here.

| Area | Before | Now |
| --- | --- | --- |
| Autosave | Wrote on every keystroke, each write ran a **blocking** LSP format | Debounced to 1.5s; autosave never formats. Format runs only on an explicit write, with a 1s timeout |
| Treesitter | Plugin on the `main` branch while the config used the `master` API, so `ensure_installed` / `highlight` / `indent` were silently ignored and **no parser was ever installed** | Pinned to `master`, 27 parsers installed, `max_jobs = 1` (concurrent `zig cc` jobs deadlock on Windows) |
| LSP file watching | Servers watched every file under `node_modules` / `.venv` | `didChangeWatchedFiles` disabled |
| Pyright | Analysed the whole project | `diagnosticMode = "openFilesOnly"` |
| ESLint | Ran on every change | Runs on save |
| Plugin loading | All ~60 plugins loaded at startup | Lazy-loaded by filetype / command / key |
| Git blame | A `git blame` process on every cursor stop | Off by default, toggle with `<leader>gb` |
| Cursor animation | 200 FPS redraw | 60 FPS |
| Large files | No protection | Highlighting, LSP and diagnostics switch off above 512 KB or on very long lines |
| Startup | ~1150 ms | **~230 ms** |

### Added

- **`:Run` (`<leader>rr`)** - compiles and runs the current file: C, C++, Python, Java, JavaScript, TypeScript, Rust, C#
- **Uzbek diagnostics** - LSP error messages translated to Uzbek, toggled with `:XatoTarjima`. The rules were written against the real messages emitted by clangd, pyright and ts_ls
- **`jdtls`** - Java language server (upstream had none)
- **Large-file guard** (`lua/nitro/core/perf.lua`)
- **PowerShell 7** as the shell, using the recipe from `:help shell-pwsh`

### Fixed

- `nvim-tree` only accepted `\` as a path separator on Windows, so creating `src/utils/` failed with *"Couldn't create file"*. Forward slashes are now normalised.
- Keys that were both a command and a prefix (`<leader>f`, `<leader>t`, `<leader>g`, `<leader>r`) caused a 400 ms wait on every press. Format moved to `<leader>cf`, tests to `<leader>T`.
- `nvim-tree` config was duplicated three times (520 lines) - collapsed into one table.
- Removed `auto-save.nvim` (duplicated a built-in autocmd) and `editorconfig-vim` (built into Neovim 0.9+).

## Table of Contents

- [Features](#features)
- [Keybindings](#keybindings)
- [Commands](#commands)
- [Installation](#installation)
- [Plugins](#plugins)
- [Language Support](#language-support)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## Features

- **LSP Integration** - Native language server support
- **Smart Completion** - Context-aware suggestions
- **Fuzzy Finding** - Quick file and text search with `ripgrep` / `fd`
- **File Explorer** - Tree-style project navigation
- **20+ Themes** - With transparency support
- **Lazy Loading** - Plugins load on demand, not at startup
- **Git Integration** - Built-in source control
- **Run & Debug** - One key to compile and run, DAP for stepping
- **Transparent UI** - Adjustable window and panel opacity

## Keybindings

Leader key is `<Space>`. Press the keys **one after another**, not together:
`<leader>ff` means Space, then f, then f.

### Files & windows

| Key | Action |
| --- | --- |
| `<leader>e` | Toggle file explorer |
| `<leader>o` / `<leader>h` | Focus file explorer |
| `<leader>n` | Reveal current file in the tree |
| `<leader>er` | Refresh the tree |
| `<C-s>` | Save |
| `<leader>q` | Close buffer |
| `<leader>k` / `<leader>j` | Next / previous buffer |
| `<leader>w` | Back to the previous window |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Move between windows |
| `<Esc>` | Clear search highlight |

Inside the file explorer: `a` new file (end with `/` for a folder, `src/utils/a.py` creates both),
`d` delete, `r` rename, `x`/`c` then `p` move/copy, `U` show hidden folders, `g?` full key list.

### Search - Telescope

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep across the project |
| `<leader>fw` | Search the word under the cursor |
| `<leader>fb` | Open buffers |
| `<leader>fo` | Recent files |
| `<leader>fs` | Symbols in this file |
| `<leader>fd` | All diagnostics |
| `<leader>fh` | Help tags |

### LSP

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `K` | Hover documentation |
| `gr` | Find references |
| `gi` / `gD` / `gt` | Implementation / declaration / type definition |
| `<leader>ca` or `F` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>cf` | Format document |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>xx` | All diagnostics (Trouble) |
| `<leader>xX` | Diagnostics in this file |
| `<leader>cs` / `<leader>cl` | Symbols / LSP info (Trouble) |
| `<C-Space>` | Trigger completion |
| `<Tab>` / `<C-k>` | Next completion item / jump in snippet |

### Code

| Key | Action |
| --- | --- |
| `gcc` | Toggle comment on the current line |
| `gc` | Toggle comment on a selection or motion |
| `ggVG` then `gc` | Comment the whole file |
| `<leader>rr` | **Run the current file** |
| `ga.` | Change case (camelCase / snake_case / ...) |

### Terminal

| Key | Action |
| --- | --- |
| `<leader>t` | Toggle a terminal at the bottom |
| `<C-\>` | Floating terminal |
| `<Esc><Esc>` | Leave terminal mode |
| `<leader>lg` | Lazygit |

### Git

| Key | Action |
| --- | --- |
| `]h` / `[h` | Next / previous hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gb` | Toggle line blame |

### Tests & debugging

| Key | Action |
| --- | --- |
| `<leader>Tn` | Run nearest test |
| `<leader>Tf` | Run all tests in the file |
| `<leader>Ts` / `<leader>To` | Test summary / output |
| `F5` | Start / continue debugging |
| `F10` / `F11` / `F12` | Step over / into / out |
| `<leader>db` / `<leader>dB` | Toggle / clear breakpoints |

## Commands

### Running code

| Command | Description |
| --- | --- |
| `:Run` | Compile and run the current file (same as `<leader>rr`) |

### Performance & diagnostics

| Command | Description |
| --- | --- |
| `:NitroPerf` | Size, LSP clients, treesitter and large-file state of the current buffer |
| `:NitroLspInfo` | Which language servers are enabled, which are missing |
| `:NitroFormatToggle` | Turn format-on-save on/off globally |
| `:NitroNoFormat` | Turn format-on-save off for this buffer only |
| `:NitroAutoSave on\|off` | Turn autosave on/off |
| `:XatoTarjima on\|off` | Uzbek / English diagnostic messages |
| `:XatoAsl` | Show the original English text of this file's diagnostics |

### Shell

The shell is PowerShell 7. One exception: `:TSInstallSync` depends on `cmd` syntax and fails under
PowerShell. Plain `:TSInstall` does not go through the shell and works fine.

| Command | Description |
| --- | --- |
| `:UseCmdShell` | Switch to `cmd.exe` temporarily |
| `:UsePowerShell` | Switch back |

### UI & project

| Command | Description |
| --- | --- |
| `:ThemeSwitch` | Theme picker with live preview (`Tab` to preview) |
| `:TransparentToggle` | Toggle transparency |
| `:FileExplorer left\|right\|center` | Move the file tree |
| `:MkDir <path>` | Create a folder |
| `:VTerm <n>` | Open n terminals |
| `:CloseAllBuffers` | Close every buffer except the current one |
| `:NitroLearn` | Vim cheat sheet |
| `:Tutor` | Official interactive Vim tutorial |

## Installation

### Prerequisites

- [Neovim](https://github.com/neovim/neovim/blob/master/INSTALL.md) **>= 0.11** (tested on 0.12) - this fork uses `vim.lsp.config` / `vim.lsp.enable` and `vim.diagnostic.jump`
- [Git](https://git-scm.com/downloads)
- [Node.js](https://nodejs.org/en/download) >= 18 - required by several language servers
- **A C compiler** - treesitter builds parsers from source. `gcc`, `clang`, `cl` or `zig` all work
- [ripgrep](https://github.com/BurntSushi/ripgrep) and [fd](https://github.com/sharkdp/fd) - for Telescope search
- [A Nerd Font](https://www.nerdfonts.com/font-downloads) - otherwise icons show as boxes
- [Lazygit](https://github.com/jesseduffield/lazygit) (optional, for `<leader>lg`)

### Windows (PowerShell)

```powershell
winget install Neovim.Neovim
winget install BurntSushi.ripgrep.MSVC
winget install sharkdp.fd
winget install BrechtSanders.WinLibs.POSIX.UCRT   # gcc / g++ for treesitter and :Run
winget install JesseDuffield.lazygit              # optional

git clone https://github.com/lxz-401/NitroVim "$env:LOCALAPPDATA\nvim"
```

### Linux / macOS

```bash
git clone https://github.com/lxz-401/NitroVim ~/.config/nvim
```

### First launch

Open `nvim`. Plugins install automatically, then treesitter parsers compile in the background -
this takes a few minutes the first time. After that, check everything with:

```vim
:checkhealth
:NitroLspInfo
```

## Plugins

- nvim-tree (file explorer)
- telescope.nvim (fuzzy finder)
- mason.nvim (LSP installer)
- nvim-cmp + LuaSnip (completion and snippets)
- nvim-treesitter (syntax, `master` branch)
- toggleterm (terminal)
- gitsigns (git)
- bufferline / lualine (tabs and status line)
- noice.nvim (UI)
- trouble.nvim (diagnostics list)
- neotest + nvim-dap (tests and debugging)
- project.nvim / auto-session (projects and sessions)

## Language Support

| Language | Server | Run with `<leader>rr` |
| --- | --- | --- |
| C / C++ | clangd | yes (`gcc` / `g++`) |
| Python | pyright (+ ruff if installed) | yes |
| Java | jdtls | yes (`javac` + `java`) |
| JavaScript / TypeScript / React | ts_ls, eslint, tailwindcss, emmet | yes (`node` / `tsx`) |
| Rust | rust_analyzer | yes (`cargo` or `rustc`) |
| C# / .NET | csharp_ls | yes (`dotnet run`) |
| HTML / CSS / JSON | html, cssls, jsonls | - |
| Lua | lua_ls | yes |

## Customization

### Adding plugins

Edit `lua/nitro/plugins/plugins.lua`. Give every plugin a loading trigger so startup stays fast:

```lua
{
  "author/plugin-name",
  ft = "python",        -- or: event = ..., cmd = ..., keys = ...
  opts = {},
}
```

### Changing settings

`lua/nitro/core/options.lua`

### Custom keymaps

`lua/nitro/core/keymaps.lua`. Do not add a key that starts with an existing single key -
`<leader>t` and `<leader>tx` together make Neovim wait 400 ms on every `<leader>t`.

### Adding a diagnostic translation

Run `:XatoAsl` to see the original English message, then add a rule to
`lua/nitro/core/diagnostics_uz.lua`:

```lua
{ "[Ee]xpected ';' after expression", "bu yerda ';' qo'yilmagan" },
```

## Troubleshooting

| Problem | Check |
| --- | --- |
| Icons show as boxes | Install a Nerd Font and select it in your terminal |
| No completion / no errors shown | `:NitroLspInfo`, then `:Mason` to install what's missing |
| No syntax colours | `:TSInstall <language>`, one at a time |
| Editor feels slow | `:NitroPerf` for this file, `:Lazy profile` for startup |
| Saving is slow | `:NitroFormatToggle` - if that fixes it, the formatter is the cause |
| `:TSInstall` hangs | Install parsers one at a time; concurrent compiler jobs deadlock on Windows |
| Still slow on Windows | Use Windows Terminal, and exclude your project folder and `%LOCALAPPDATA%\nvim-data` from Windows Defender |

## Credits

Forked from [NitroVim/NitroVim](https://github.com/NitroVim/NitroVim) by the original authors.
Licensed under the same terms - see [LICENSE](./LICENSE).

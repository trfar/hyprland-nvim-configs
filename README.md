# Trfar Hyprland & Nvim Configs:

Configuration for my Neovim & Hyprland installations.

## Layout:

- `hypr/` — Hyprland config. `hyprland.lua` is the main file; `monitors.lua` is the per-machine escape hatch (gitignored, optional); `.env` is the per-machine values (gitignored, created from `.env.example`)
- `nvim/` — Neovim config
- `scripts/` — install scripts
- `docs/` — guides + generated keymap reference

## Docs:

- `docs/Neovim-Basics.md` — this preset in five minutes, then in parts
- `docs/Neovim-Workflows.md` — plugin by plugin, basic + advanced
- `docs/Hyprland-Basics.md` — the Hyprland mental map (workspaces, layouts, keymap, `hyprctl`)
- `docs/Hammerspoon.md` — the Mac tiling side: model, keymap, setup, gotchas
- `docs/keys.md` — full keymap reference, generated from the config (`scripts/keys.sh`)

## Hyprland:

### New machine (Arch / CachyOS / ...):

```sh
git clone git@github.com:trfar/hyprland-nvim-configs.git
cd hyprland-nvim-configs
scripts/arch.sh          # Arch/CachyOS/...: installs packages (pacman) + symlinks hypr/ into ~/.config/hypr
scripts/debian.sh        # Debian 13+ (trixie): installs packages (apt) + symlinks hypr/ into ~/.config/hypr
```

Then edit `hypr/.env` for your machine and log out / back in.

### What you need to set per machine:

**`hypr/.env`** — created by the script from `.env.example` if missing. Every key is optional; missing/empty falls back to the default in `hyprland.lua` (which matches my desktop).

| Key | What it controls |
| --- | --- |
| `PRIMARY_MONITOR` | Main monitor name (workspace 1's home, wallpaper target) |
| `SECONDARY_MONITOR` | Second monitor. **Set to empty for a single-monitor setup** — all workspaces 1-10 then live on the one monitor with the scrolling layout. In dual setups 1-5 go to primary (scrolling), 6-10 to secondary (master layout) |
| `MONITOR_<n>` | Optional per-monitor pin: `<name> <mode> <position>` (see below) |
| `WALLPAPER_PRIMARY` / `WALLPAPER_SECONDARY` | swaybg wallpaper paths at startup (empty = skip that monitor) |
| `TERMINAL`, `MENU`, `BROWSER`, `OBSIDIAN`, `FILEMANAGER` | The apps launched by the keybinds |

Find your monitor names with `hyprctl monitors` (after logging into Hyprland).

**Per-machine monitor pins** — in `hypr/.env`, not in a file: `MONITOR_<n>=<name> <mode> <position>` (e.g. `MONITOR_1=DP-1 2560x1440@144 auto-right`). Without pins Hyprland auto-detects (usually right for a single built-in display); find your values with `hyprctl monitors -j | jq` (one-liner in `.env.example`). `hypr/monitors.lua` remains as an optional escape hatch for anything the .env form can't express (rotation, per-monitor vrr) — it's gitignored and takes precedence over the .env pins if present.

**`hypr/hyprlock.conf`** — the two `background` blocks hardcode my monitor names (`DP-1`/`DP-2`) and wallpaper paths. On a new machine set the `monitor =` lines to your monitor names (and `path` to an existing image), or delete both blocks for a plain lock screen.

**Not in pacman:** `obsidian` is AUR-only (`obsidian-bin`), and `strata` is my custom file-manager binary — copy it from your old machine to `~/.local/bin/strata` or point `FILEMANAGER` in `hypr/.env` at something else (e.g. `thunar`).

### Existing machine (manual, no script):

Symlink each file from `hypr/` into `~/.config/hypr/` (`hyprland.lua`, `monitors.lua`, `hyprlock.conf`, `hypridle.conf`, and `.env` if you have one). That's how `~/.config/hypr` is set up on my current desktop.

## Neovim:

### Install (macOS, Apple Silicon):

```sh
git clone git@github.com:trfar/hyprland-nvim-configs.git
cd hyprland-nvim-configs
scripts/mac.sh           # brew: neovim + ripgrep/fd/lazygit + hammerspoon, symlinks nvim/ and hammerspoon/
```

Plugins, LSP servers and treesitter parsers install themselves on first nvim run (slow the first time). Requires Homebrew first — the script tells you how if it's missing.

### Hammerspoon (Mac window management)

`hammerspoon/init.lua` mirrors the SUPER (⌘) keybinds from `hypr/hyprland.lua`: column tiling, vim focus/swap (⌘hjkl / ⌘⇧hjkl), send window to other monitor (⌘⌥h/l), per-display workspaces (⌘1–0 switch, ⌘⇧1–0 send), and the launcher keys. It is not a WM — no borders or master layout; "float" excludes a window from the tiler. Full reference, what to expect, and gaps vs Hyprland: `docs/Hammerspoon.md`. Needs Accessibility + Input Monitoring permissions. Reload: menu bar icon → Reload.

### Windows (work machines, no admin needed):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\win.ps1   # scoop (user-level) + junctions nvim/ into %USERPROFILE%\.config\nvim
```

### .env

The nvim/.env.example has global variables you must copy enter & copy over to your shell source file (Instructions within the file for fish vs bash shells). These variables include settings for:

- nvim's CodeCompanion - AI Pair Programming

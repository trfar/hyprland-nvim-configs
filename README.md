# Trfar Hyprland & Nvim Configs:

Configuration for my Neovim & Hyprland installations.

## Layout:

- `hypr/` — Hyprland config. `hyprland.lua` is the main file; `monitors.lua` is the per-machine monitor setup (optional); `.env` is the per-machine values (gitignored, created from `.env.example`)
- `nvim/` — Neovim config
- `scripts/` — install scripts

## Hyprland:

### New machine (Arch / CachyOS / ...):

```sh
git clone <this repo>
cd hyprland-nvim-configs
scripts/arch.sh          # installs packages + symlinks hypr/ into ~/.config/hypr
```

Then edit `hypr/.env` for your machine and log out / back in.

### What you need to set per machine:

**`hypr/.env`** — created by the script from `.env.example` if missing. Every key is optional; missing/empty falls back to the default in `hyprland.lua` (which matches my desktop).

| Key | What it controls |
| --- | --- |
| `PRIMARY_MONITOR` | Main monitor name (workspace 1's home, wallpaper target) |
| `SECONDARY_MONITOR` | Second monitor. **Set to empty for a single-monitor setup** — all workspaces 1-10 then live on the one monitor with the scrolling layout. In dual setups 1-5 go to primary (scrolling), 6-10 to secondary (master layout) |
| `WALLPAPER_PRIMARY` / `WALLPAPER_SECONDARY` | swaybg wallpaper paths at startup (empty = skip that monitor) |
| `TERMINAL`, `MENU`, `BROWSER`, `OBSIDIAN`, `FILEMANAGER` | The apps launched by the keybinds |

Find your monitor names with `hyprctl monitors` (after logging into Hyprland).

**`hypr/monitors.lua`** — per-monitor resolution, position and rotation. Only needed if you want to pin those; if the file doesn't exist Hyprland auto-detects (usually fine for a single built-in display). One `hl.monitor` block per monitor, e.g.:

```lua
hl.monitor({ output = "eDP-1", mode = "1920x1200@60" })
```

**`hypr/hyprlock.conf`** — the two `background` blocks hardcode my monitor names (`DP-1`/`DP-2`) and wallpaper paths. On a new machine set the `monitor =` lines to your monitor names (and `path` to an existing image), or delete both blocks for a plain lock screen.

**Not in pacman:** `obsidian` is AUR-only (`obsidian-bin`), and `strata` is my custom file-manager binary — copy it from your old machine to `~/.local/bin/strata` or point `FILEMANAGER` in `hypr/.env` at something else (e.g. `thunar`).

### Existing machine (manual, no script):

Symlink each file from `hypr/` into `~/.config/hypr/` (`hyprland.lua`, `monitors.lua`, `hyprlock.conf`, `hypridle.conf`, and `.env` if you have one). That's how `~/.config/hypr` is set up on my current desktop.

## Neovim:

### .env

The nvim/.env.example has global variables you must copy enter & copy over to your shell source file (Instructions within the file for fish vs bash shells). These variables include settings for:

- nvim's CodeCompanion - AI Pair Programming

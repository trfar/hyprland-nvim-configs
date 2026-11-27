# Hammerspoon — the Mac tiling side

For someone new to the macOS window-management setup. `hammerspoon/init.lua` mirrors the SUPER (⌘) binds from `hypr/hyprland.lua` so the same muscle memory carries over. Verified on macOS 26.5.2, Hammerspoon 1.1.1.

## The model — what to expect

**N managed windows on a display = N equal columns.** One window fills the screen (minus the menu bar) — the same behavior as Hyprland's `fullscreen_on_one_column`. A second window splits it in half, and so on, with 3px gaps between columns.

- It is *not* a window manager: no borders, no master/stacking layout, no scrolling past the screen edge. Columns only.
- "Floating" (`⌘⇧V`) means *excluded from the tiler*, not z-order floating — Hammerspoon 1.1.1 has no window-level float API. The window stays exactly where you left it; press again and it re-joins the tiling.
- Workspaces are the per-display macOS user Spaces (turn **Displays have separate Spaces** on). `⌘1`–`⌘0` index *that display's* Spaces, in order.
- Never tiled: the desktop background, notification banners, minimized windows, and anything you've excluded.

## Keybind reference

| Key | Action |
| --- | --- |
| `⌃⌘R` | Force re-tile everything (escape hatch after anything goes sideways) |
| `⌘⇧V` | Exclude / restore the focused window from tiling |
| `⌘h` / `⌘j` / `⌘k` / `⌘l` | Focus the window left / down / up / right (wraps horizontally) |
| `⌘⇧h/j/k/l` | **Swap** the focused window's frame with the neighbour |
| `⌘⌥h` / `⌘⌥l` | Move the focused window to the other monitor |
| `⌘1`–`⌘0` | Switch to the Nth user Space on the display with focus |
| `⌘⇧1`–`⌘0` | Send the focused window to that Space |
| `⌘S` | Terminal (Alacritty) — new window |
| `⌘W` | Finder |
| `⌘Q` | Browser (Zen) |
| `⌘⇧A` | Obsidian |
| `⌘`` ` | Close the focused window |
| `⌘Esc` | Quit the active app |
| `⌘M` | Shut down |

Left native and untouched: Spotlight (menu key), `⌃⌘Q` lock, `⌘⇧4` screenshot, `⌃⌘F` fullscreen.

## Setup

- `scripts/mac.sh` brew-installs Hammerspoon and symlinks `hammerspoon/` into `~/.hammerspoon`. On first run, open the Hammerspoon app and approve the **Accessibility** and **Input Monitoring** prompts — without them the hotkeys and the space-sending drag silently do nothing.
- After editing the config: menu bar icon → **Reload**. There is deliberately no reload hotkey (a stale ⌘bind would eat keys you didn't ask for).
- Per-machine tuning lives at the top of `init.lua`:
  - `apps` table — the launcher targets (terminal / fileManager / browser / obsidian)
  - `GAP` — pixels between columns · `ANIM` — animation duration in seconds
  - `MENUBAR` — top inset so the tiler doesn't run under the menu bar; bump it for a taller one

## Gotchas / gaps vs Hyprland

- Space switches flash Mission Control briefly — that's the native switch, not a bug.
- Sending a window to another Space (`⌘⇧N`) is a **visible simulated drag** of the title bar to the screen edge. `hs.spaces.moveWindowToSpace` is broken on macOS 15/26 (Hammerspoon #3698), so the script does the macOS-native thing: grab the window, drag it to the edge, let the OS switch Spaces with it. The tiler is paused for ~2s per Space crossed while that happens. Needs Input Monitoring.
- `⌘1` may collide with the system App Exposé shortcut — if `⌘1` does nothing, free it under System Settings → Keyboard → Keyboard Shortcuts → Mission Control.

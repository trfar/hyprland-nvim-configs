# Hyprland Basics — the mental map

For someone new to this Hyprland setup. One idea unlocks everything; the rest is reference.

## The model

**Monitors hold workspaces, workspaces hold windows.** You never dock a window "to the
left half of the screen" — you send it to a *workspace*, and the workspace tiles its
windows automatically. There is no snapping and no drag-to-resize: tiling *is* the
window management.

- Workspaces are numbered `1`–`10` (the `0` key is workspace 10).
- Dual monitor (this desktop): `1–5` live on the main monitor, `6–10` on the second.
- Single monitor (laptop): all ten live on the one screen.

```
[ monitor 1 (main) ]              [ monitor 2 ]
workspaces 1–5                    workspaces 6–10
scrolling layout (columns)        master layout (big window + stack)
```

## The two layouts

- **Scrolling** (workspaces 1–5): windows are *columns*. One window fills the screen;
  a second gives two half-columns; you scroll between them like a shelf.
  - `SUPER + .` / `SUPER + ,` scroll the view right / left
  - `SUPER + [` / `SUPER + ]` merge the column into / un-merge it from its neighbour
  - `SUPER + R` (and `SUPER + SHIFT + R`) cycle column widths
- **Master** (workspaces 6–10): one big window on top, everything else stacked below it.
  - `SUPER + Return` promote the focused window to the big slot
  - `SUPER + O` cycle the stack direction (top / right / bottom / left)

Any window can go to any workspace, so "which layout am I in" just means "which number
did I send it to".

## Keymap (`SUPER` = the Windows key)

**Apps**

| Key | Does |
| --- | --- |
| `SUPER + S` | new terminal |
| `SUPER + Q` | scratchpad terminal — persistent, toggles in and out |
| `SUPER + W` | file manager |
| `SUPER + Tab` | browser |
| `SUPER + A` | Obsidian |
| `SUPER + Space` | app menu (fuzzel) — type anything, Enter runs it |

**Window control**

| Key | Does |
| --- | --- |
| `SUPER + H J K L` | focus the window left / down / up / right |
| `SUPER + SHIFT + H J K L` | *move* the focused window that way |
| `SUPER + ALT + H` / `L` | send the window to the other monitor (and follow it) |
| `SUPER + 1…9, 0` | go to that workspace · `SUPER + SHIFT + 1…0` send the window there |
| `SUPER + scroll` | cycle through existing workspaces |
| `SUPER + grave` | close the window |
| `SUPER + V` | float / un-float · `SUPER + F` fullscreen |
| `SUPER + LMB drag` / `RMB drag` | move / resize with the mouse |
| `SUPER + SHIFT + C` | screenshot a region to the clipboard |

**System:** `SUPER + Esc` lock · `SUPER + M` logout/shutdown · media keys just work
(volume, mute, mic mute, player controls).

## The debug loop: `hyprctl`

Everything the keymap does, the CLI can do — the keybinds are just wrappers around
these. When something misbehaves:

```sh
hyprctl monitors     # what Hyprland sees: names, modes, positions
hyprctl dispatch …   # do anything: hyprctl dispatch workspace 3, focus, …
hyprctl reload       # re-read the config without logging out
```

Rule of thumb: if you can do it with `hyprctl dispatch`, you can bind it.

## The config (where to change things)

| File | What |
| --- | --- |
| `hyprland.lua` | the shared config — look, keybinds, workspaces |
| `.env` | **per machine** (gitignored): monitor names, wallpapers, which apps the binds launch, monitor pins |
| `monitors.lua` | optional escape hatch for per-monitor pins (resolution / position / rotation) |
| `hyprlock.conf` | lock-screen backgrounds (hardcodes monitor names — edit per machine) |
| `hypridle.conf` | lock / screens-off / suspend timers |

Edit, then `hyprctl reload` (or log out/in for monitor changes).


#!/usr/bin/env bash
# arch.sh — Hyprland setup for Arch-based distros (Arch, CachyOS, EndeavourOS, ...).
#
# Does three things:
#   1. Installs the packages the hyprland config needs (pacman)
#   2. Symlinks hypr/* into ~/.config/hypr (existing real files are backed up to *.bak)
#   3. Creates hypr/.env from .env.example if it doesn't exist yet
#
# Usage:
#   scripts/arch.sh                # packages + links + .env
#   SKIP_PACKAGES=1 scripts/arch.sh  # links + .env only (manage packages yourself)
#
# After it finishes:
#   1. Edit hypr/.env for your machine (monitor names via `hyprctl monitors`)
#   2. Adjust hypr/monitors.lua (per-monitor resolution/position) if needed
#   3. Log out / back in (or `hyprctl reload`)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$HOME/.config/hypr"

# --- 1. Packages -----------------------------------------------------------
# Not in pacman (install with your AUR helper or skip):
#   obsidian-bin        (AUR) — note app, see OBSIDIAN in hypr/.env
#   strata              custom binary, copy it to ~/.local/bin/strata or
#                       point FILEMANAGER in hypr/.env at something else
if [ "${SKIP_PACKAGES:-0}" != "1" ]; then
	sudo pacman -S --needed \
		hyprland \
		hyprlock \
		hypridle \
		alacritty \
		fuzzel \
		grim \
		slurp \
		wl-clipboard \
		swaybg \
		zen-browser \
		pipewire \
		wireplumber \
		playerctl \
		xdg-desktop-portal-hyprland
else
	echo ">> SKIP_PACKAGES=1 — skipping pacman"
fi

# --- 2. Symlink config files ------------------------------------------------
link() {
	local src="$1" dest="$2"
	if [ -L "$dest" ]; then
		ln -sfn "$src" "$dest"
	elif [ -e "$dest" ]; then
		mv "$dest" "$dest.bak"
		echo "   backed up existing $dest -> $dest.bak"
		ln -sfn "$src" "$dest"
	else
		ln -sfn "$src" "$dest"
	fi
	echo "   linked $dest -> $src"
}

mkdir -p "$CFG"
echo ">> Linking config files into $CFG"
for f in hyprland.lua monitors.lua hyprlock.conf hypridle.conf; do
	link "$ROOT/hypr/$f" "$CFG/$f"
done

# --- 3. .env -----------------------------------------------------------------
if [ ! -e "$ROOT/hypr/.env" ]; then
	cp "$ROOT/hypr/.env.example" "$ROOT/hypr/.env"
	echo "   created $ROOT/hypr/.env (copy of .env.example)"
fi
link "$ROOT/hypr/.env" "$CFG/.env"

echo
echo ">> Done. Next steps:"
echo "   1. Edit $ROOT/hypr/.env  (SECONDARY_MONITOR empty = single-monitor setup;"
echo "      find monitor names with: hyprctl monitors)"
echo "   2. Check $ROOT/hypr/monitors.lua (resolution/position per monitor;"
echo "      optional — delete it to let Hyprland auto-detect)"
echo "   3. Check $ROOT/hypr/hyprlock.conf background blocks (they hardcode"
echo "      monitor names and wallpaper paths)"
echo "   4. Log out / back in, or: hyprctl reload"

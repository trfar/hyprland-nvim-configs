#!/usr/bin/env bash
# arch.sh — set up Hyprland on Arch-based distros (Arch, CachyOS, EndeavourOS, ...).
#
# Steps:
#   1. Install the packages this config needs (pacman; SKIP_PACKAGES=1 to skip)
#   2. Symlink hypr/* into ~/.config/hypr (existing real files are moved to *.bak)
#   3. Create hypr/.env from .env.example if missing, then symlink it
#
# Not in pacman (manual): obsidian-bin (AUR), strata (custom binary -> ~/.local/bin)
#
# After running: edit hypr/.env (monitor names via `hyprctl monitors`),
# then log out/in or `hyprctl reload`.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$HOME/.config/hypr"

#1. packages --------------------------------------------------------------
if [ "${SKIP_PACKAGES:-0}" != "1" ]; then
	# compositor + lock + idle | terminal | launcher | screenshots + clipboard
	# wallpaper daemon | browser | audio stack + media keys | file-dialog portals
	sudo pacman -S --needed \
		hyprland hyprlock hypridle \
		alacritty \
		fuzzel \
		grim slurp wl-clipboard \
		swbg \
		zen-browser \
		pipewire wireplumber playerctl \
		xdg-desktop-portal-hyprland
else
	echo ">> SKIP_PACKAGES=1 — skipping pacman"
fi

#2. symlinks into ~/.config/hypr ------------------------------------------
link() { # src dest — refresh symlink; back up an existing real file to *.bak
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

#3. .env — per-machine values (gitignored) ---------------------------------
if [ ! -e "$ROOT/hypr/.env" ]; then
	cp "$ROOT/hypr/.env.example" "$ROOT/hypr/.env"
	echo "   created $ROOT/hypr/.env (copy of .env.example)"
fi
link "$ROOT/hypr/.env" "$CFG/.env"

echo
echo ">> Done. Next: edit $ROOT/hypr/.env (SECONDARY_MONITOR empty = single monitor),"
echo "   check hypr/monitors.lua and the hyprlock.conf background blocks, then log out/in."

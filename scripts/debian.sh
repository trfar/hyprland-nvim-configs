#!/usr/bin/env bash
# debian.sh — set up Hyprland on Debian (13 "trixie" or newer; bookworm has no hyprland).
#
# Same steps as arch.sh, but with apt:
#   1. Install the packages this config needs (apt; SKIP_PACKAGES=1 to skip)
#   2. Symlink hypr/* into ~/.config/hypr (existing real files are moved to *.bak)
#   3. Create hypr/.env from .env.example if missing, then symlink it
#
# After running: edit hypr/.env (monitor names via `hyprctl monitors`),
# then log out/in or `hyprctl reload`.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$HOME/.config/hypr"

#1. packages --------------------------------------------------------------
if [ "${SKIP_PACKAGES:-0}" != "1" ]; then
	sudo apt-get update
	# compositor + lock + idle | terminal | launcher | screenshots + clipboard
	# wallpaper daemon | audio stack + media keys | file-dialog portals
	sudo apt-get install -y \
		hyprland hyprlock hypridle \
		alacritty \
		fuzzel \
		grim slurp wl-clipboard \
		swbg \
		pipewire wireplumber playerctl \
		xdg-desktop-portal-wlr
else
	echo ">> SKIP_PACKAGES=1 — skipping apt"
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

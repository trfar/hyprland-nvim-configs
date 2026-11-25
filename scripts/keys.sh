#!/usr/bin/env bash
# keys.sh — regenerate docs/keys.md from the config's own keymaps.
#
# Runs the nvim config headless under an isolated XDG_CONFIG_HOME (a temp dir
# containing a symlink to this repo's nvim/), so it works from a bare clone on
# any machine and never touches your real config.
#
# Requires: nvim on PATH, plugins already installed (open nvim once normally
# first — the first run installs plugins and LSP servers, and it makes the
# "on attach" section of the output complete).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v nvim >/dev/null || { echo "nvim not found on PATH" >&2; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ln -s "$ROOT/nvim" "$tmp/nvim"

mkdir -p "$ROOT/docs"
XDG_CONFIG_HOME="$tmp" nvim --headless \
	-c 'lua require("docs.keys").dump()' \
	-c 'qa!' > "$ROOT/docs/keys.md"

echo ">> wrote $ROOT/docs/keys.md"

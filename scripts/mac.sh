#!/usr/bin/env bash
# mac.sh — Neovim setup for macOS (Apple Silicon; Intel also works, Homebrew is arch-aware).
#
# Steps:
#   1. Install neovim + the binaries this config needs (Homebrew; SKIP_PACKAGES=1 to skip)
#   2. Symlink nvim/ into ~/.config/nvim (an existing real dir is moved to nvim.bak)
#
#   NVIM_AI_* env vars for CodeCompanion — copy the block from nvim/.env.example
#     into your shell config (~/.zshrc / ~/.bashrc / fish config.fish)
#
# Requires Neovim >= 0.12 (the config uses vim.pack); brew's `neovim` is current stable.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIMCFG="$HOME/.config/nvim"

#1. packages ---------------------------------------------------------------
if [ "${SKIP_PACKAGES:-0}" != "1" ]; then
	# Homebrew lives in /opt/homebrew on Apple Silicon; add it if the shell hasn't yet
	if ! command -v brew >/dev/null && [ -x /opt/homebrew/bin/brew ]; then
		export PATH="/opt/homebrew/bin:$PATH"
	fi
	command -v brew >/dev/null || {
		echo ">> Homebrew not found. Install it first, then re-run this script:"
		echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
		echo "   then in ~/.zprofile:  eval \"\$(/opt/homebrew/bin/brew shellenv)\""
		exit 1
	}
	# neovim | telescope search backends (live_grep=find_files) | lazygit UI
	brew install neovim ripgrep fd lazygit
else
	echo ">> SKIP_PACKAGES=1 — skipping brew"
fi

#2. symlink config into ~/.config/nvim --------------------------------------
link() { # src dest — refresh symlink; back up an existing real file/dir to *.bak
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

mkdir -p "$HOME/.config"
link "$ROOT/nvim" "$NVIMCFG"

echo
echo ">> nvim version: $(nvim --version 2>/dev/null | head -n1 || echo 'not on PATH')"
echo ">> Done. Next:"
echo "   1. Open nvim — plugins, LSP servers and treesitter parsers install on first run"
echo "   2. Copy the NVIM_AI_* block from $ROOT/nvim/.env.example into your shell config"
echo "   3. Only if a parser fails to build (needs a C compiler): xcode-select --install"

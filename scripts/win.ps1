# win.ps1 — Neovim setup for Windows (no admin required).
#
# Steps:
#   1. Ensure Scoop (user-level install, no admin; SKIP_PACKAGES=1 to skip)
#   2. Install neovim + the binaries this config needs (scoop)
#   3. Junction %USERPROFILE%\.config\nvim -> <repo>\nvim
#      (a junction, not a symlink: creating symlinks needs admin or Developer Mode)
#
# Run:  powershell -ExecutionPolicy Bypass -File scripts\win.ps1
#
# Requires Neovim >= 0.12 (the config uses vim.pack).

$ErrorActionPreference = 'Stop'

$Root    = Split-Path -Parent $PSScriptRoot
$NvimCfg = Join-Path $env:USERPROFILE '.config\nvim'

#1. packages -----------------------------------------------------------------
if ($env:SKIP_PACKAGES -ne '1') {
	if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
		Write-Host '>> Scoop not found — installing (user-level, no admin)'
		irm get.scoop.sh | iex
	}
	# a fresh Scoop is not on this shell's PATH yet
	$env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"
	# neovim | telescope search backends (live_grep=find_files) | lazygit UI
	scoop install neovim ripgrep fd lazygit
} else {
	Write-Host '>> SKIP_PACKAGES=1 — skipping scoop'
}

#2. junction config into %USERPROFILE%\.config\nvim --------------------------
New-Item -ItemType Directory -Force -Path (Split-Path $NvimCfg) | Out-Null
if (Test-Path $NvimCfg) {
	$existing = Get-Item $NvimCfg
	if ($existing.LinkType) {
		Remove-Item $NvimCfg # removes the junction/symlink itself, not the target
	} else {
		$bak = "$NvimCfg.bak"
		if (Test-Path $bak) { throw "backup $bak already exists — move it first" }
		Rename-Item $NvimCfg $bak
		Write-Host "   backed up existing $NvimCfg -> $bak"
	}
}
New-Item -ItemType Junction -Path $NvimCfg -Target "$Root\nvim" | Out-Null
Write-Host "   linked $NvimCfg -> $Root\nvim"

Write-Host ''
Write-Host ">> nvim version: $(nvim --version 2>$null | Select-Object -First 1)"
Write-Host '>> Done. Next:'
Write-Host '   1. Open nvim in a NEW terminal (so scoop shims are on PATH) — plugins, LSP servers and treesitter parsers install on first run'
Write-Host '   2. Copy the NVIM_AI_* values from nvim\.env.example into your profile ($env: in PowerShell, or setx for a persistent default)'

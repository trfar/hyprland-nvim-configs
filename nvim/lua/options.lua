-- Core options: leaders, display, editing, search, clipboard

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- Nerd Font (JetBrains Mono): plugins show icons when true
vim.g.have_nerd_font = true

-- Display
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false -- statusline already shows the mode
vim.o.signcolumn = 'yes' -- keep the git-diff gutter visible
vim.o.cursorline = true
vim.o.scrolloff = 18
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Editing
vim.o.breakindent = true
vim.o.undofile = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.confirm = true -- prompt to save before commands that would delete the buffer
vim.o.inccommand = 'split' -- live-preview substitutions

-- Search: case-insensitive unless the pattern contains capitals
vim.o.ignorecase = true
vim.o.smartcase = true

-- Timings
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Sync Neovim & system clipboard (deferred so it doesn't slow startup)
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

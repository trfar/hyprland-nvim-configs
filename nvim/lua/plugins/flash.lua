-- flash.nvim: jump to any character in the buffer (gs) / treesitter select (gS)
local gh = require('plugins').gh

vim.pack.add { gh 'folke/flash.nvim' }
require('flash').setup {}
vim.keymap.set({ 'n', 'x', 'o' }, 'gs', function() require('flash').jump() end, { desc = 'Flash jump' })
vim.keymap.set({ 'n', 'x', 'o' }, 'gS', function() require('flash').treesitter() end, { desc = 'Flash treesitter select' })

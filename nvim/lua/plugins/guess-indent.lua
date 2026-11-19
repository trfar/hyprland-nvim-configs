-- Auto-adjust indent style to match the file being edited
local gh = require('plugins').gh

vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {}

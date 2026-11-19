-- Markdown: browser preview (GitHub-style, <leader>mp) + in-buffer rendering
local gh = require('plugins').gh

-- Browser preview: keep open when switching buffers
vim.g.mkdp_auto_close = 0
vim.g.mkdp_theme = 'dark' -- or 'light'
vim.pack.add { gh 'iamcco/markdown-preview.nvim' }

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(ev) vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', { buffer = ev.buf, desc = '[M]arkdown [P]review toggle' }) end,
})

-- In-buffer rendering
vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }
require('render-markdown').setup {}

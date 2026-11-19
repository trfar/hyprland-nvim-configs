-- Autocomplete: blink.cmp engine with luasnip snippets
local gh = require('plugins').gh

-- Snippet engine + community vscode snippet pack
vim.pack.add { gh 'L3MON4D3/LuaSnip' }
require('luasnip').setup {}
vim.pack.add { gh 'rafamadriz/friendly-snippets' }
require('luasnip.loaders.from_vscode').lazy_load()

-- Completion engine (pinned to this Neovim major)
vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }

require('blink.cmp').setup {
  keymap = {
    -- Preset adds <c-space> to open, <tab>/<s-tab> for snippet nav, <up>/<down> to select
    preset = 'enter',
  },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },
  sources = {
    -- 'buffer' as a fallback so words in the file always complete
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
  signature = { enabled = true },
}

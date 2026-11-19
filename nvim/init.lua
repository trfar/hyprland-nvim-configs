-- Neovim entry point.
-- Components are plain Lua modules under lua/: options & keymaps at the top,
-- one file per plugin under lua/plugins/. Loaded in the order below.

-- Faster startup: lazy-load Neovim's bundled Lua modules
vim.loader.enable()

require 'options'
require 'keymaps'

-- Plugin infrastructure first: pack build hooks must exist before vim.pack.add
require 'plugins'

require 'plugins.guess-indent'
require 'plugins.gitsigns'
require 'plugins.lazygit'
require 'plugins.which-key'
require 'plugins.colorscheme'
require 'plugins.mini'
require 'plugins.telescope'
require 'plugins.lsp'
require 'plugins.conform'
require 'plugins.blink'
require 'plugins.treesitter'
require 'plugins.autopairs'
require 'plugins.codecompanion'
require 'plugins.flash'
require 'plugins.markdown'

-- vim: ts=2 sts=2 sw=2 et

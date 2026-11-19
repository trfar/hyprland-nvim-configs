-- conform.nvim: formatting per filetype + format-on-save
local gh = require('plugins').gh

vim.pack.add { gh 'stevearc/conform.nvim' }
require('conform').setup {
  notify_on_error = false,
  -- Only format on save for these filetypes
  format_on_save = function(bufnr)
    local enabled_filetypes = {
      lua = true,
      rust = true,
      cpp = true,
      c = true,
      python = true,
    }
    if enabled_filetypes[vim.bo[bufnr].filetype] then
      return { timeout_ms = 500 }
    else
      return nil
    end
  end,
  default_format_opts = {
    lsp_format = 'fallback',
  },
  formatters_by_ft = {
    rust = { 'rustfmt' },
    cpp = { 'clang-format' },
    c = { 'clang-format' },
    python = { 'isort', 'black' },
    lua = { 'stylua' },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })

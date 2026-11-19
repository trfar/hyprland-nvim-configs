-- LSP: fidget activity UI, per-buffer keymaps, server configs, mason installs
local gh = require('plugins').gh

-- fidget: spinner/statusline UI for LSP activity
vim.pack.add { gh 'j-hui/fidget.nvim' }
require('fidget').setup {}

-- Per-buffer keymaps once an LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    -- Highlight references under the cursor, clear on move
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      -- Detach LSP when a Buffer is Cleared
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end
    -- Inlay hints toggle, if supported
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- Server configs
---@type table<string, vim.lsp.Config>
local servers = {
  -- lua_ls: point at the project's .luarc.json if present, else stdlib-only
  -- settings so Neovim config files don't trigger third-party indexing
  lua_ls = {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end
      local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
      client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          -- Load only standard Neovim runtime to prevent background indexing freeze
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = { enable = true },
      },
    },
  },
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        cargo = { features = { 'ssr' } },
        completion = {
          postfix = { enable = true },
          autoimport = { enable = true },
        },
      },
    },
  },
}

-- mason: installs & manages LSP servers and tools
vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}
require('mason').setup {}
require('mason-lspconfig').setup {
  automatic_enable = { exclude = { 'stylua' } }, -- stylua is a formatter here, not a wanted LSP
}
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  'ty',
  'ruff',
  'rust_analyzer',
  'clangd',
  'bash-language-server',
  'yaml-language-server',
})
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

-- Register each server, injecting completion capabilities
for name, server in pairs(servers) do
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    server.capabilities = blink.get_lsp_capabilities(server.capabilities)
  else
    server.capabilities = vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), server.capabilities or {})
  end
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

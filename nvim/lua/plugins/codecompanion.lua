-- codecompanion.nvim: AI chat & inline edits against a local OpenAI-compatible
-- endpoint (env vars from .env, defaults match a local llama.cpp server)
local gh = require('plugins').gh

local ai_url = vim.env.NVIM_AI_URL or 'http://localhost:8080'
local ai_model_name = vim.env.NVIM_AI_MODEL_NAME
local ai_api_key = vim.env.NVIM_AI_API_KEY or 'none'
local ai_chat_url = vim.env.NVIM_AI_CHAT_URL or '/v1/chat/completions'

vim.pack.add { gh 'olimorris/codecompanion.nvim' }
require('codecompanion').setup {
  adapters = {
    http = {
      local_llm = function()
        return require('codecompanion.adapters').extend('openai_compatible', {
          env = {
            url = ai_url,
            api_key = ai_api_key,
            chat_url = ai_chat_url,
          },
          schema = {
            model = { default = ai_model_name },
          },
        })
      end,
    },
  },
  strategies = {
    chat = { adapter = 'local_llm' },
    inline = { adapter = 'local_llm' },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionChat Toggle<cr>', { desc = '[A]I [A] chat toggle' })
vim.keymap.set({ 'n', 'v' }, '<leader>ac', '<cmd>CodeCompanionActions<cr>', { desc = '[A]I [C]ommands/actions' })
vim.keymap.set('v', 'ga', '<cmd>CodeCompanionChat Add<cr>', { desc = '[A]dd selection to AI chat' })
vim.cmd [[cnoreabbrev cc CodeCompanion]]

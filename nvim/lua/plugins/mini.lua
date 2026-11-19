-- mini.nvim toolbox: icons, file explorer (mini.files), extended text
-- objects (mini.ai), surrounding (mini.surround), statusline
local gh = require('plugins').gh

vim.pack.add { gh 'nvim-mini/mini.nvim' }

-- Icons, only with a Nerd Font
if vim.g.have_nerd_font then require('mini.icons').setup() end

-- mini.files: file explorer, open with '-', close with 'q'
require('mini.files').setup {
  mappings = {
    close = 'q',
  },
}
vim.keymap.set('n', '-', function()
  if not MiniFiles.close() then MiniFiles.open() end
end, { desc = 'Open mini.files' })

-- Open files from the explorer into new splits
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf = args.data.buf_id
    -- Vertical split to the right
    vim.keymap.set('n', '<C-v>', function()
      local target = MiniFiles.get_explorer_state().target_window
      local new_target = vim.api.nvim_win_call(target, function()
        vim.cmd 'belowright vertical split'
        return vim.api.nvim_get_current_win()
      end)
      MiniFiles.set_target_window(new_target)
      MiniFiles.go_in()
    end, {
      buffer = buf,
      desc = 'Open in vertical split',
    })
    -- Horizontal split below
    vim.keymap.set('n', '<C-x>', function()
      local target = MiniFiles.get_explorer_state().target_window
      local new_target = vim.api.nvim_win_call(target, function()
        vim.cmd 'belowright horizontal split'
        return vim.api.nvim_get_current_win()
      end)
      MiniFiles.set_target_window(new_target)
      MiniFiles.go_in()
    end, {
      buffer = buf,
      desc = 'Open in horizontal split',
    })
  end,
})

-- mini.ai: extra text objects (aa = around next, ii = inside next)
require('mini.ai').setup {
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

-- mini.surround: manage surrounding characters
require('mini.surround').setup()

-- mini.statusline
local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end

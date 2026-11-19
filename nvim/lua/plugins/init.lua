-- Plugin infrastructure: GitHub shorthand + per-plugin build hooks.
-- Must load before any vim.pack.add so PackChanged sees every install/update.
--
-- vim.pack is Neovim's built-in plugin manager:
--   :lua vim.pack.update()                     update plugins
--   :lua vim.pack.update(nil, { offline = true }) inspect pending updates

-- GitHub URL shorthand: gh 'owner/repo'
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- Run a build command, notifying on failure
local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local stderr = result.stderr or ''
    local stdout = result.stdout or ''
    local output = stderr ~= '' and stderr or stdout
    if output == '' then output = 'No output from build command.' end
    vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
  end
end

-- Build plugins that need compiling after install or update
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make' }, ev.data.path)
      return
    end

    if name == 'LuaSnip' then
      if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
      return
    end

    if name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
      return
    end

    if name == 'markdown-preview.nvim' then
      if vim.fn.executable 'npm' == 1 then run_build(name, { 'npm', 'install' }, ev.data.path .. '/app') end
      return
    end
  end,
})

return { gh = gh }

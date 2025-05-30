return {
  {
    -- Install markdown preview, use npm if available.
    -- if this fails, manually install using :call mkdp#util#install()
    'iamcco/markdown-preview.nvim',
    keys = {
      { '<leader>cp', '<Cmd>MarkdownPreviewToggle<CR>', 'Markdown Preview Toggle' },
    },
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function(plugin)
      if vim.fn.executable('npm') then
        vim.cmd('!cd ' .. plugin.dir .. ' && cd app && npm install')
      else
        vim.cmd([[Lazy load markdown-preview.nvim]])
        vim.fn['mkdp#util#install']()
      end
    end,
    init = function()
      if vim.fn.executable('npm') then vim.g.mkdp_filetypes = { 'markdown' } end
    end,
  },
}

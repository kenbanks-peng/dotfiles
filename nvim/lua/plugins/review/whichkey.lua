-- opts merged with lavyvim config
return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts_extend = { 'spec' },
    config = function()
      require('which-key').add({
        { '<leader>b', group = '+buffer' },
        { '<leader>c', group = '+code' },
        { '<leader>d', group = '+lsp', icon = '' },
        { '<leader>f', group = '+find/+file' },
        { '<leader>g', group = '+git' },
        { '<leader>q', group = '+session' },
        { '<leader>s', group = '+search' },
        { '<leader>u', group = '+toggle' },
        { '<leader>x', group = '+lists', icon = '' },
        { '<leader>y', group = '+yazi', icon = '󰇥' },
      })
    end,
  },
}

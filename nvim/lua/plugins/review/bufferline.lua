return {
  {
    'akinsho/bufferline.nvim',
    keys = {
      { 'H',         '<cmd>BufferLineCyclePrev<CR>', 'Prev Buffer' },
      { 'L',         '<cmd>BufferLineCycleNext<CR>', 'Next Buffer' },
      { '<S-Tab>',   '<cmd>BufferLineCyclePrev<CR>', 'Prev Buffer' },
      { '<Tab>',     '<cmd>BufferLineCycleNext<CR>', 'Next Buffer' },
      -- related buffer mappings
      { '<C-S-Tab>', '<cmd>tabnew %<CR>',            'New Tab' },
      { '<leader>`', '<cmd>e #<CR>',                 'switch buffer' },
    }
  }
}

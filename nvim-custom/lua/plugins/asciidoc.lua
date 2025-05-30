return {
  {
    'tigion/nvim-asciidoc-preview',
    ft = { 'asciidoc' },
    build = 'cd server && npm install',
    opts = {
      -- Add user configuration here
    },
  }
}

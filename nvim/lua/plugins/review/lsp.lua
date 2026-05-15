return {
  {
    -- collection of lsp config defaults so we don't have to
    'neovim/nvim-lspconfig',
    -- will merge with lavyvim config
    dependencies = {
      -- status updates for LSP loading - bottom right corner
      { 'j-hui/fidget.nvim', opts = {} },
    },
    opts = function(_, opts)
      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

      local servers = {
        -- See `:help lspconfig-all` for a list of all the pre-configured LSPs

        -- lua_ls configured by lazyvim
        -- lua_ls = {
        --   settings = {
        --     Lua = {
        --       -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        --       -- diagnostics = { disable = { 'missing-fields' } },
        --     },
        --   },
        -- },

        marksman = {},
        -- equivalent to nvim-lspconfig defaults:
        --   require 'lspconfig'.marksman.setup({
        --     cmd = { "marksman", "server" },
        --     filetypes = { "markdown", "markdown.mdx" },
        --     root_dir = root_pattern(".git", ".marksman.toml"),
        --     single_file_support = true
        --   })
      }

      -- keep: use left, force: use right
      opts.servers = vim.tbl_deep_extend('force', opts.servers, servers)
    end,
  },
}

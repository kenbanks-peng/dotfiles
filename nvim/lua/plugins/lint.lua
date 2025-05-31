-- mason to install linters
-- nvim-lint to lint the code
return {
  {
    "williamboman/mason.nvim",
    opts = {
      -- tbd
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        -- tbd
      },
      linters = {
        -- tbd
      },
    },
  },
}

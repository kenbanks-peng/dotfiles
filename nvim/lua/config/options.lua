-- -- Options are automatically loaded before lazy.nvim startup
-- -- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- -- Add any additional options here

-- local opt = vim.opt
-- local o = vim.o
-- local g = vim.g
-- local schedule = vim.schedule
-- local fn = vim.fn
-- local env = vim.env

-- ------- globals -------

-- -- g.base46_cache = vim.fn.stdpath "data" .. "/lazy/"
-- g.mapleader = ' ' -- `:help mapleader`. NOTE: must be before plugins loaded
-- g.maplocalleader = ','
-- g.have_nerd_font = true

-- ------- options -------
-- -- See `:help vim.opt` and `:help option-list`

-- opt.shortmess:append('sI') -- disable nvim intro

-- -- Indenting
-- o.expandtab = true
-- o.shiftwidth = 2
-- o.smartindent = true
-- o.tabstop = 2
-- o.softtabstop = 2

-- -- Numbers
-- o.number = true -- line numbers
-- o.numberwidth = 2
-- o.ruler = false
-- o.relativenumber = true -- relative line numbers
-- o.cursorline = true -- Show which line your cursor is on
-- o.cursorlineopt = 'number'

-- o.laststatus = 3 -- avante.nvim views can only be fully collapsed with the global statusline
-- o.showmode = false -- mode already in the status line

-- o.mouse = 'a' -- Enable mouse mode

-- opt.fillchars = { eob = ' ' }
-- o.ignorecase = true -- unless \C or one or more capital letters used
-- o.smartcase = true

-- o.signcolumn = 'yes'
-- o.splitbelow = true -- how new splits should be opened
-- o.splitright = true

-- o.undofile = true -- Save undo history

-- o.timeoutlen = 300 -- to display which-key popup sooner
-- o.updatetime = 250 -- interval for writing swap file to disk

-- --  Schedule to reduce startup-time.
-- schedule(function()
--   o.clipboard = 'unnamedplus' -- -- Sync clipboard between OS and Neovim.`:help 'clipboard'`
-- end)

-- o.breakindent = true -- Enable break indent
-- o.inccommand = 'split' -- Preview substitutions live, as you type!
-- o.scrolloff = 10 -- Minimal number of screen lines to keep above and below the cursor.

-- -- go to previous/next line with h,l,left arrow and right arrow
-- -- when cursor reaches end/beginning of line
-- opt.whichwrap:append('<>[]hl')

-- -- disable some default providers
-- -- g.loaded_node_provider = 0
-- -- g.loaded_python3_provider = 0
-- -- g.loaded_perl_provider = 0
-- -- g.loaded_ruby_provider = 0

-- -- Sets how neovim will display certain whitespace characters in the editor.
-- --  See `:help 'list'`
-- --  and `:help 'listchars'`
-- o.list = true
-- opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- -- add binaries installed by mason.nvim to path
-- local is_windows = fn.has('win32') ~= 0
-- local sep = is_windows and '\\' or '/'
-- local delim = is_windows and ';' or ':'
-- env.PATH = table.concat({ fn.stdpath('data'), 'mason', 'bin' }, sep) .. delim .. env.PATH

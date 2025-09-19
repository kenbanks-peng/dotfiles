-- KEYMAPS - automatically loaded on the VeryLazy event

local map = function(keys, func, desc) vim.keymap.set('n', keys, func, { desc = desc, silent = true, noremap = true }) end

-- delete unwanted LazyVim/Plugin mappings
-- local del = vim.keymap.del

-- del('n', '<leader>L')          -- LazyVim Changelog
-- del('n', '<leader>K')          -- man keyword lookup
-- del('n', '<C-Up>')             -- Resize window
-- del('n', '<C-Down>')           -- Resize window
-- del('n', '<C-Left>')           -- Resize window
-- del('n', '<C-Right>')          -- Resize window
-- del('n', '<leader>qq')         -- quit all

-- del('n', '<leader><Tab>[')     -- real vim tabs
-- del('n', '<leader><Tab>d')     -- real vim tabs
-- del('n', '<leader><Tab>]')     -- real vim tabs
-- del('n', '<leader><Tab><Tab>') -- real vim tabs
-- del('n', '<leader><Tab>f')     -- real vim tabs
-- del('n', '<leader><Tab>o')     -- real vim tabs
-- del('n', '<leader><Tab>l')     -- real vim tabs

-- del('n', '[b')                 -- Prev Buffer
-- del('n', ']b')                 -- Next Buffer
-- del('n', '<leader>bl')         -- Delete Buffers to the Left
-- del('n', '<leader>br')         -- Delete Buffers to the Right
-- del('n', '<leader>bo')         -- Delete Other Buffers
-- del('n', '<leader>bP')         -- Delete Non-Pinned Buffers
-- del('n', '<leader>bp')         -- Toggle Pin

-- del('n', '<M-k>')              -- Move Code Up
-- del('n', '<M-j>')              -- Move Code Down

-- del('n', '<leader>|')          -- Split Window Right <C-W>v                                             Split Window Right
-- del('n', '<leader>-')          -- Split Window Below <C-W>s                                             Split Window Below

-- -- NEOTREE -- cannot disable - so remove keys
-- del('n', '<leader>E')  -- Explorer NeoTree (cwd)
-- del('n', '<leader>e')  -- Explorer NeoTree (Root Dir)
-- del('n', '<leader>fE') -- Explorer NeoTree (cwd)
-- del('n', '<leader>fe') -- Explorer NeoTree (Root Dir)

-------------------
--     NVIM      --
-------------------
-- Remap Q to start/stop recording a macro (requires a register)
-- vim.keymap.set('n', 'Q', 'q', { noremap = true })

-------------------
--  DIAGNOSTICS  --
-------------------
-- map('<leader>xf', vim.diagnostic.setloclist, 'quickfix list')

-------------------
--   TERMINAL    --
-------------------
-- vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-------------------
--    WEZTERM    --
-------------------
-- depending on situation, send command to neovim or to wezterm
local wezterm = require('custom.wezterm')
-- splits
map('<leader>\\', '<C-w>v', 'split right')
map('<leader>/', '<C-w>s', 'split down')
-- navigate splits   -- ok
map('<S-Left>', function() wezterm.navigate('h') end, 'navigate left')
map('<S-Down>', function() wezterm.navigate('j') end, 'navigate down')
map('<S-Up>', function() wezterm.navigate('k') end, 'navigate up')
map('<S-Right>', function() wezterm.navigate('l') end, 'navigate right')
-- resize splits   -- ok
map('<M-Left>', function() wezterm.resize('h', 2) end, 'resize left')
map('<M-Down>', function() wezterm.resize('j', 2) end, 'resize down')
map('<M-Up>', function() wezterm.resize('k', 2) end, 'resize up')
map('<M-Right>', function() wezterm.resize('l', 2) end, 'resize right')

-- manage conflict instead of depending on lazy load order
-- local builtin = require('telescope.builtin')
-- map('<leader>sf', builtin.find_files, 'telescope search files')
-- map('<leader><space>', '<cmd>Yazi toggle<cr>', 'yazi toggle')

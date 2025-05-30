return {
  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>ys', '<cmd>Yazi<cr>', desc = 'yazi same' },
      { '<leader>yr', '<cmd>Yazi cwd<cr>', desc = 'yazi root' },
      { '<leader><space>', '<cmd>Yazi toggle<cr>', desc = 'yazi toggle' },
    },
    opts = {
      -- hitting enter on a directory usually pulls up netrw
      -- open_for_directories = true,

      -- an upcoming optional feature. See
      -- https://github.com/mikavilpas/yazi.nvim/pull/152
      use_ya_for_events_reading = true,

      -- an upcoming optional feature
      use_yazi_client_id_flag = true,

      -- an upcoming optional feature. See
      -- https://github.com/mikavilpas/yazi.nvim/pull/180
      -- highlight_groups = {
      --   -- NOTE: this only works if `use_ya_for_events_reading` is enabled, etc.
      --   hovered_buffer = nil,
      -- },

      -- the floating window scaling factor. 1 means 100%, 0.9 means 90%, etc.
      floating_window_scaling_factor = 1.0,

      -- the transparency of the yazi floating window (0-100). See :h winblend
      yazi_floating_window_winblend = 0,

      -- the log level to use. Off by default, but can be used to diagnose
      -- issues. You can find the location of the log file by running
      -- `:checkhealth yazi` in Neovim. Also check out the "reproducing issues"
      -- section below
      -- log_level = vim.log.levels.OFF,

      -- what Neovim should do a when a file was opened (selected) in yazi.
      -- Defaults to simply opening the file.
      -- open_file_function = function(chosen_file, config, state) end,

      -- customize the keymaps that are active when yazi is open and focused. The
      -- defaults are listed below. Also:
      -- - use e.g. `open_file_in_tab = false` to disable a keymap
      -- - you can customize only some of the keymaps if you want
      keymaps = {
        show_help = '<f1>', -- TODO: conflicts with WezTerm
        -- open_file_in_vertical_split = '<c-v>',
        -- open_file_in_horizontal_split = '<c-x>',
        -- open_file_in_tab = '<c-t>',
        -- grep_in_directory = '<c-s>',
        -- replace_in_directory = '<c-g>',
        -- cycle_open_buffers = '<tab>',
        -- copy_relative_path_to_selected_files = '<c-y>',
        -- send_to_quickfix_list = '<c-q>',
      },

      -- completely override the keymappings for yazi. This function will be
      -- called in the context of the yazi terminal buffer.
      -- set_keymappings_function = function(yazi_buffer_id, config, context) end,

      -- the type of border to use for the floating window. Can be many values,
      -- including 'none', 'rounded', 'single', 'double', 'shadow', etc. For
      -- more information, see :h nvim_open_win
      -- yazi_floating_window_border = 'rounded',

      -- some yazi.nvim commands copy text to the clipboard. This is the register
      -- yazi.nvim should use for copying. Defaults to "*", the system clipboard
      -- clipboard_register = '*',

      -- hooks = {
      --   -- if you want to execute a custom action when yazi has been opened,
      --   -- you can define it here.
      --   yazi_opened = function(preselected_path, yazi_buffer_id, config)
      --     -- you can optionally modify the config for this specific yazi
      --     -- invocation if you want to customize the behaviour
      --   end,

      --   -- when yazi was successfully closed
      --   yazi_closed_successfully = function(chosen_file, config, state) end,

      --   -- when yazi opened multiple files. The default is to send them to the
      --   -- quickfix list, but if you want to change that, you can define it here
      --   yazi_opened_multiple_files = function(chosen_files, config, state) end,
      -- },

      -- integrations = {
      --   --- What should be done when the user wants to grep in a directory
      --   grep_in_directory = function(directory)
      --     -- the default implementation uses telescope if available, otherwise nothing
      --   end,
      --   grep_in_selected_files = function(selected_files)
      --     -- similar to grep_in_directory, but for selected files
      --   end,
      --   --- Similarly, search and replace in the files in the directory
      --   replace_in_directory = function(directory)
      --     -- default: grug-far.nvim
      --   end,
      --   replace_in_selected_files = function(selected_files)
      --     -- default: grug-far.nvim
      --   end,
      --   -- `grealpath` on OSX, (GNU) `realpath` otherwise
      --   resolve_relative_path_application = '',
      -- },
    },
  },
}

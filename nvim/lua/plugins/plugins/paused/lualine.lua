-- AVAILABLE COMPONENTS
-- branch (git branch)
-- buffers (shows currently available buffers)
-- diagnostics (diagnostics count from your preferred source)
-- diff (git diff status)
-- encoding (file encoding)
-- fileformat (file format)
-- filename
-- filesize
-- filetype
-- hostname
-- location (location in file in line:column format)
-- mode (vim mode)
-- progress (%progress in file)
-- searchcount (number of search matches when hlsearch is active)
-- selectioncount (number of selected characters or lines)
-- tabs (shows currently available tabs)
-- windows (shows currently available windows)

-- lazyvim config: opts.sections
--   .lualine_a: mode
--   .lualine_b: branch
--   .lualine_c: root_dir, diagnostics icon, filetype icon, pretty_path
--   .lualine_x: noice.api.status.command, noice.api.status.mode, dap.status, lazy.status.updates, git status
--   .lualine_y: progress, location
--   .lualine_z: clock

-- opts.sections - statusline
-- opts.tabline.sections - tabline
-- opts.winbar.sections - winbar

return {
  {
    'nvim-lualine/lualine.nvim',
    opts = function(_, opts)
      -- opts.options.theme = "powerline_dark"
      opts.winbar = {
        lualine_z = {
          {
            'selectioncount',
          },
        },
      }
      return opts
    end,
  },
}

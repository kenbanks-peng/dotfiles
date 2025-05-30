-- lazy.nvim example:
return {
  {
    'tim-harding/neophyte',
    tag = '0.3.0',
    event = 'VeryLazy',
    opts = {
      fonts = {
        {
          name = 'Cascadia Code PL',
          features = {
            {
              name = 'calt',
              value = 1,
            },
            -- Shorthand to set a feature to 1
            'ss01',
            'ss02',
          },
        },
        -- Shorthand for no features or variations
        'Symbols Nerd Font',
        'Apple Color Emoji',
      },
      font_size = {
        kind = 'width', -- 'width' | 'height'
        size = 10,
      },
      -- Multipliers of the base animation speed.
      -- To disable animations, set these to large values like 1000.
      cursor_speed = 2,
      scroll_speed = 2,
      -- Increase or decrease the distance from the baseline for underlines.
      underline_offset = 1,
      -- For transparent window effects, use this to set the default background color.
      -- This is because most colorschemes in transparent mode unset the background,
      -- which normally defaults to the terminal background, but we don't have that here.
      -- You must also pass --transparent as a command-line argument to see the effect.
      -- Channel values are in the range 0-255.
      bg_override = {
        r = 48,
        g = 52,
        b = 70,
        a = 128,
      },
    },
  },
}

-- Alternatively, the guifont option is supported:
-- vim.opt.guifont = 'Cascadia Code PL:w10, Symbols Nerd Font, Noto Color Emoji'

-- There are also freestanding functions to set these options as desired:

-- Increase font size
-- vim.keymap.set('n', '<c-+>', function()
--   neophyte.set_font_width(neophyte.get_font_width() + 1)
-- end)

-- Decrease font size
-- vim.keymap.set('n', '<c-->', function()
--   neophyte.set_font_width(neophyte.get_font_width() - 1)
-- end)

-- Use cmd-ctrl-f to toggle fullsreen on MacOS
-- if this_os:find('Darwin') then
--  vim.keymap.set('n', '<DC-f>', function()
--    neophyte.set_fullscreen(not neophyte.get_fullscreen())
--  end)
--end

--   foreground = '#cdd6f4',      -- Mocha text
--   background = '#1e1e2e',      -- Mocha base
--   scrollbar_thumb = '#595b70', -- Mocha surface2
--   cursor_bg = '#eba0ad',       -- Mocha maroon
--   cursor_border = '#eba0ad',   -- Mocha maroon
--   cursor_fg = '#11111b',       -- Mocha crust
--   selection_bg = '#11111b',    -- Mocha crust
--   selection_fg = '#f9e2af',    -- Mocha text
--   compose_cursor = '#f2cdcd',  -- Mocha flamingo
--   split = '#454759',           -- Mocha surface1
--   visual_bell = '#f38ba8'      -- Mocha red

-- catppucchin mocha
local mocha = {
   rosewater = '#f5e0dc',
   flamingo = '#f2cdcd',
   pink = '#f5c2e7',
   mauve = '#cba6f7',
   red = '#f38ba8',
   maroon = '#eba0ac',
   peach = '#fab387',
   yellow = '#f9e2af',
   green = '#a6e3a1',
   teal = '#94e2d5',
   sky = '#89dceb',
   sapphire = '#74c7ec',
   blue = '#89b4fa',
   lavender = '#b4befe',
   text = '#cdd6f4',
   subtext1 = '#bac2de',
   subtext0 = '#a6adc8',
   overlay2 = '#9399b2',
   overlay1 = '#7f849c',
   overlay0 = '#6c7086',
   surface2 = '#585b70',
   surface1 = '#45475a',
   surface0 = '#313244',
   base = '#1e1e2e',
   mantle = '#181825',
   crust = '#11111b',
}


-- some programs use standard and others use brights
-- too difficult so just make them all the same
local colors = {
   foreground = mocha.text,
   background = mocha.base,
   cursor_bg = mocha.rosewater,
   cursor_border = mocha.rosewater,
   cursor_fg = mocha.crust,
   selection_bg = mocha.surface2,
   selection_fg = mocha.text,
   ansi = {
      mocha.crust,  -- black alternative
      mocha.red,    -- red
      mocha.green,  -- green
      mocha.yellow, -- yellow
      mocha.blue,   -- blue
      mocha.peach,  -- purple (orange)
      mocha.teal,   -- cyan
      mocha.text,   -- white
   },
   brights = {
      mocha.crust,  -- black alternative
      mocha.red,    -- red
      mocha.green,  -- green
      mocha.yellow, -- yellow
      mocha.blue,   -- blue
      mocha.peach,  -- purple (orange)
      mocha.teal,   -- cyan
      mocha.text,   -- white
   },
   tab_bar = {
      background = 'rgba(0, 0, 0, 0.4)',
      active_tab = {
         bg_color = mocha.surface2,
         fg_color = mocha.text,
      },
      inactive_tab = {
         bg_color = mocha.surface0,
         fg_color = mocha.subtext1,
      },
      inactive_tab_hover = {
         bg_color = mocha.surface0,
         fg_color = mocha.text,
      },
      new_tab = {
         bg_color = mocha.base,
         fg_color = mocha.text,
      },
      new_tab_hover = {
         bg_color = mocha.mantle,
         fg_color = mocha.text,
         italic = true,
      },
   },
   visual_bell = mocha.surface0,
   indexed = {
      [16] = mocha.peach,
      [17] = mocha.rosewater,
   },
   scrollbar_thumb = mocha.surface2,
   split = mocha.overlay0,
   compose_cursor = mocha.flamingo, -- nightbuild only
}

return colors


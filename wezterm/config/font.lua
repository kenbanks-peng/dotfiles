local wezterm = require('wezterm')

--   weight: Thin, ExtraLight, Light, DemiLight, Book, Regular, Medium, DemiBold, Bold, ExtraBold, Black, ExtraBlack
--   style: Normal, Italic, Oblique
--   stretch??: UltraCondensed, ExtraCondensed, Condensed, SemiCondensed, Normal, SemiExpanded, Expanded, ExtraExpanded, UltraExpanded
--   monospace (Monaspice) Ar (humanist sans), Ne (neo-grotesque sans), Xe (slab serif), Rn (handwriting), Kr (mechanical sans)
--   hasklig (Hasklug Nerd Font Mono)
local font = 'Hasklug Nerd Font Mono' -- based on hasklig
local font_options = { weight = 'Regular', style = 'Normal', stretch = 'Normal' }
local font_size = 18

return {
   font = wezterm.font(font, font_options),
   font_size = font_size,
   line_height = 1.0,
   cell_width = 1.0,
   freetype_load_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
   freetype_render_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}


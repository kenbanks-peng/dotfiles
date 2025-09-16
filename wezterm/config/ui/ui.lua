local colors = require('config.ui.colors')
local background = require('config.ui.background')

return {
   -- color scheme
   colors = colors,

   -- background layers
   background = background,

   -- cursor
   -- SteadyBlock BlinkingBlock SteadyUnderline BlinkingUnderline SteadyBar BlinkingBar
   default_cursor_style = 'SteadyBar',

   -- scrollbar
   enable_scroll_bar = true,

   -- tab bar
   enable_tab_bar = true,
   hide_tab_bar_if_only_one_tab = true,
   use_fancy_tab_bar = true,
   tab_max_width = 25,
   show_tab_index_in_tab_bar = true,
   switch_to_last_active_tab_when_closing_tab = true,

   -- window
   window_decorations = 'RESIZE | INTEGRATED_BUTTONS| MACOS_FORCE_DISABLE_SHADOW', -- NONE, TITLE, RESIZE, INTEGRATED_BUTTONS, MACOS_FORCE_DISABLE_SHADOW
   window_padding = {
      top = 20,
      right = 5, -- scrollbar width
      bottom = 20,
      left = 30,
   },
   window_close_confirmation = 'NeverPrompt',
   inactive_pane_hsb = {
      saturation = 0.9,
      brightness = 0.65,
   },
}

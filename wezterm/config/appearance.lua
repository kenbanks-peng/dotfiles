local gpu_adapters = require('util.gpu_adapter')
local colors = require('colors.custom')

return {
   animation_fps = 60,
   max_fps = 60,
   front_end = 'WebGpu',
   webgpu_power_preference = 'HighPerformance',
   webgpu_preferred_adapter = gpu_adapters:pick_best(),

   -- cursor
   -- SteadyBlock BlinkingBlock SteadyUnderline BlinkingUnderline SteadyBar BlinkingBar
   default_cursor_style = 'SteadyBar',

   -- color scheme
   colors = colors,

   -- background
   background = {
      -- {
      --    source = { File = wezterm.GLOBAL.background },
      --    horizontal_align = 'Center',
      -- },
      {
         source = { Color = colors.background },
         height = '100%',
         width = '100%',
         opacity = 1.0,
      },
   },

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
   window_decorations = 'RESIZE', -- NONE, TITLE, RESIZE, TITLE|RESIZE
   window_padding = {
      top = 40,
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

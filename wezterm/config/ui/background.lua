-- background layers

local wezterm = require('wezterm')
local colors = require('config.ui.colors')

local layers = {
  {
    source = { Color = colors.background },
    height = '100%',
    width = '100%',
    opacity = 1.0,
  },
}



local function create_transparent_layer()
  return {
    {
      source = { Color = colors.background },
      width = "100%",
      height = "100%",
      opacity = 0.2,
    }
  }
end

-- key binding mapped to toggle-layers event
wezterm.on('toggle-layers', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.background then
    overrides.background = create_transparent_layer()
  else
    overrides.background = nil
  end
  window:set_config_overrides(overrides)
end)


return layers

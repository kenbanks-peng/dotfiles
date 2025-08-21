local wezterm = require 'wezterm'
local mux = wezterm.mux
local config = {}

wezterm.on('gui-startup', function(cmd)
   local tab, pane, window = mux.spawn_window {
      args = { 'zsh', '-l', '-c', '/opt/homebrew/bin/zellij' },
   }
end)

return config

-- type `wezterm show-keys` in the terminal to see the key bindings

local wezterm = require('wezterm')
local action = wezterm.action
local quick_select = require('config.keymaps.quick_select')
local quick_select_patterns = quick_select.quick_select_patterns
local quick_select_open_url = quick_select.quick_select_open_url

-- Mod keys: Super/Cmd, Ctrl, Alt, LeftAlt, RightAlt, Shift, LeftShift, RightShift
--
-- Named keys:
--   PageUp (fn up), PageDown (fn down), End (fn right), Home (fn left)
--   LeftArrow, RightArrow, UpArrow, DownArrow,
--   Tab, Enter, Escape,CapsLock,
--   F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,
--   F13, F14, F15, F16, F17, F18, F19, F20, F21, F22, F23, F24

local mod = {
   NONE = 'NONE',
   META = 'ALT',
   CTRL = 'CTRL',
   SHIFT = 'SHIFT',
   SUPER = 'CMD',
   SUPER_REV = 'CMD|META',
   LEADER = 'LEADER',
}

local function map(key, mods, act)
   return { key = key, mods = mods, action = act }
end


local function eventmap(event, mods, act)
   return { event = event, mods = mods, action = act }
end

local function close_pane_or_tab(window, pane)
   local tab = window:active_tab()
   if #tab:panes() > 1 then
      window:perform_action(action.CloseCurrentPane({ confirm = false }), pane)
   else
      window:perform_action(action.CloseCurrentTab({ confirm = false }), pane)
   end
end

local command = '/Users/ken/Software/DevBox/scripts/bin/dir'

local function directory_paste(window, pane)
   local success, stdout, stderr = wezterm.run_child_process({ command, '-g' })
   if success then
      pane:send_text(stdout)
   else
      wezterm.log_error('dir command failed: ' .. stderr)
   end
end

local function directory_copy(window, pane)
   local cwd = pane:get_current_working_dir()
   if cwd then
      cwd = tostring(cwd)
      wezterm.run_child_process({ command, '-p', cwd })
   end
end

-- stylua: ignore
local keys = {
   -- DIRECTORY COPY/PASTE
   map("c", mod.META, wezterm.action_callback(directory_copy)),
   map("v", mod.META, wezterm.action_callback(directory_paste)),

   -- QUICK SELECT MODE
   map('f', mod.SUPER_REV, action.QuickSelect), -- ??

   -- COPY MODE
   map('g', mod.SUPER, 'ActivateCopyMode'), -- CMD+g

   -- SEARCH MODE
   map('f', mod.SUPER, action.Search({ CaseInSensitiveString = '' })), -- 'CurrentSelectionOrEmptyString'

   -- manage enter variants
   map("Enter", mod.NONE, action.SendString("\x0d")),
   map("Enter", mod.META, action.ToggleFullScreen),
   map("Enter", mod.SHIFT, action.SendString("\x1b[13;2u")), -- escape sequence for shift+enter
   map("Enter", mod.CTRL, action.SendString("\x1b[13;5u")),  -- escape sequence for ctrl+enter

   -- APPLICATION
   -- spawn windows
   map('n', mod.SUPER, action.SpawnWindow),
   map('q', mod.SUPER, action.QuitApplication), -- not required
   map('Enter', mod.META, action.ToggleFullScreen),
   map('h', mod.SUPER, action.HideApplication),
   map('r', mod.SUPER, action.ReloadConfiguration),
   map('p', mod.SUPER, action.ActivateCommandPalette),
   map('j', mod.SUPER_REV, action.ShowDebugOverlay),
   map('k', mod.SUPER_REV, action.ShowDebugOverlay),
   map('F1', mod.NONE, action.ShowLauncher),
   map('F2', mod.NONE, action.ShowLauncherArgs({ flags = 'FUZZY|TABS' })),
   map('F3', mod.NONE, action.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' })),

   -- PANE or TAB
   map('w', mod.SUPER, wezterm.action_callback(close_pane_or_tab)),

   -- TABS
   -- map('t', mod.SUPER_REV, action.SpawnTab({ DomainName = 'WSL:Ubuntu' })),
   map('t', mod.SUPER, action.SpawnTab('DefaultDomain')), -- 'CurrentPaneDomain'
   map('[', mod.SUPER, action.ActivateTabRelative(-1)),
   map(']', mod.SUPER, action.ActivateTabRelative(1)),
   map('Tab', mod.CTRL, action.ActivateTabRelative(1)),
   map('[', mod.SUPER_REV, action.MoveTabRelative(-1)),
   map(']', mod.SUPER_REV, action.MoveTabRelative(1)),
   map('1', mod.SUPER, action.ActivateTab(0)),
   map('2', mod.SUPER, action.ActivateTab(1)),
   map('3', mod.SUPER, action.ActivateTab(2)),
   map('4', mod.SUPER, action.ActivateTab(3)),
   map('5', mod.SUPER, action.ActivateTab(4)),
   map('6', mod.SUPER, action.ActivateTab(5)),
   map('7', mod.SUPER, action.ActivateTab(6)),
   map('8', mod.SUPER, action.ActivateTab(7)),
   map('9', mod.SUPER, action.ActivateTab(-1)), -- last tab

   -- FONT
   map('\u{8}', mod.SUPER, action.ResetFontSize), -- cmd + del key
   map('=', mod.SUPER, action.IncreaseFontSize),
   map('-', mod.SUPER, action.DecreaseFontSize),
   map('u', mod.SUPER, action.CharSelect({ copy_on_select = true, copy_to = 'ClipboardAndPrimarySelection' })), -- emoji

   -- PANES
   map('\\', mod.SUPER, action.SplitVertical({ domain = 'CurrentPaneDomain' })),
   map('/', mod.SUPER, action.SplitHorizontal({ domain = 'CurrentPaneDomain' })),
   map('Enter', mod.SUPER, action.TogglePaneZoomState), -- zoom
   map('p', mod.SUPER_REV, action.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' })),

   -- SCROLL
   map('PageUp', mod.SHIFT, action.ScrollByPage(-1)),
   map('PageDown', mod.SHIFT, action.ScrollByPage(1)),

   -- CURSOR MOVEMENT
   map('Home', mod.NONE, action.SendString('\x01')),            -- Move to the beginning of the line
   map('End', mod.NONE, action.SendString("\x05")),             -- Move to the end of the line
   map('LeftArrow', mod.SUPER, action.SendString("\x1bb")),     -- Move backward one word
   map('RightArrow', mod.SUPER, action.SendString("\x1bf")),    -- Move forward one word
   map('Backspace', mod.SUPER, action.SendString('\x15')),      -- Clear the current command line (Ctrl + U)
   map('RightArrow', mod.SUPER_REV, action.SendString("\x0b")), -- Clear from the cursor to the end of the line (Ctrl + K)

   -- CLEAR, COPY, PASTE, SEARCH
   map('k', mod.SUPER, action.Multiple {
      action.ClearScrollback 'ScrollbackAndViewport',
      action.SendKey { key = 'L', mods = mod.CTRL },
   }), -- clear and redraw prompt
   map('c', mod.SUPER, action.CopyTo('Clipboard')),
   map('v', mod.SUPER, action.PasteFrom('Clipboard')),


   -- Quick Select
   map('u', mod.SUPER, action.QuickSelectArgs(quick_select_open_url)),

   -- CTRL-SHIFT-l activates the debug overlay
   map('L', mod.CTRL, action.ShowDebugOverlay),

   map('B', mod.CTRL, action.EmitEvent('toggle-layers')),


   -- key-tables --
   -- resizes fonts
   map('f', mod.LEADER, action.ActivateKeyTable({
      name = 'resize_font',
      one_shot = false,
      timemout_miliseconds = 1000,
   })),

}


-- wezterm-nvim integration
-- merge nav_keys into keys
local nav_keys = require('config.keymaps.wezterm_nvim').nav_keys
for _, v in ipairs(nav_keys) do
   table.insert(keys, v)
end

local key_tables = {}
key_tables.copy_mode = {
   -- MOVE CURSOR -- 1 CHARACTER
   map('LeftArrow', mod.NONE, action.CopyMode('MoveLeft')),
   map('RightArrow', mod.NONE, action.CopyMode('MoveRight')),
   map('DownArrow', mod.NONE, action.CopyMode('MoveDown')),
   map('UpArrow', mod.NONE, action.CopyMode('MoveUp')),

   -- MOVE CURSOR -- WORDS
   map('Tab', mod.NONE, action.CopyMode('MoveForwardWord')),
   map('Tab', mod.SHIFT, action.CopyMode('MoveBackwardWord')),
   map('Tab', mod.CTRL, action.CopyMode('MoveForwardWordEnd')),

   -- MOVE CURSOR -- JUMP
   map('UpArrow', mod.SHIFT, action.CopyMode('MoveToScrollbackTop')),      -- top
   map('DownArrow', mod.SHIFT, action.CopyMode('MoveToScrollbackBottom')), -- bottom
   map('PageUp', mod.NONE, action.CopyMode('PageUp')),                     -- page up
   map('PageDown', mod.NONE, action.CopyMode('PageDown')),                 -- page down
   map('m', mod.NONE, action.CopyMode('MoveToViewportMiddle')),            -- middle
   map('d', mod.NONE, action.CopyMode({ MoveByPage = 0.5 })),              -- down
   map('u', mod.NONE, action.CopyMode({ MoveByPage = (-0.5) })),           -- up

   -- MOVE CURSOR -- LINES
   map('Enter', mod.NONE, action.CopyMode('MoveToStartOfNextLine')),
   map('Home', mod.NONE, action.CopyMode('MoveToStartOfLineContent')),
   map('End', mod.NONE, action.CopyMode('MoveToEndOfLineContent')),

   -- TOGGLE SELECTION
   map('Space', mod.NONE, action.CopyMode({ SetSelectionMode = 'Cell' })),
   map('l', mod.NONE, action.CopyMode({ SetSelectionMode = 'Line' })),
   map('b', mod.NONE, action.CopyMode({ SetSelectionMode = 'Block' })),

   -- MOVE CURSOR -- SELECTION
   map('o', mod.NONE, action.CopyMode('MoveToSelectionOtherEnd')), -- other end

   -- FINISH
   map('c', mod.NONE, action.Multiple({
      { CopyTo = 'ClipboardAndPrimarySelection' },
      { CopyMode = 'Close' }
   })),                                               -- copy
   map('Escape', mod.NONE, action.CopyMode('Close')), -- close
}

key_tables.search_mode = {
   map('UpArrow', mod.NONE, action.CopyMode('PriorMatch')),
   map('DownArrow', mod.NONE, action.CopyMode('NextMatch')),
   map('PageUp', mod.NONE, action.CopyMode('PriorMatchPage')),
   map('PageDown', mod.NONE, action.CopyMode('NextMatchPage')),
   map('t', mod.SUPER, action.CopyMode('CycleMatchType')), -- type
   map('x', mod.SUPER, action.CopyMode('ClearPattern')),   -- clear
   map('Escape', mod.NONE, action.CopyMode('Close')),      -- close
}

key_tables.resize_font = {
   map('j', mod.NONE, action.DecreaseFontSize),
   map('k', mod.NONE, action.IncreaseFontSize),
   map('r', mod.NONE, action.ResetFontSize),

   map('Escape', mod.NONE, 'PopKeyTable'),
   map('q', mod.NONE, 'PopKeyTable'),
}


local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   eventmap({ Up = { streak = 1, button = 'Left' } }, mod.CTRL, action.OpenLinkAtMouseCursor),
}

local opacity_levels = { 1.0, 0.95, 0.9, 0.85, 0.8 }
local current_opacity_index = 1


return {
   disable_default_key_bindings = true, -- reset all keys
   debug_key_events = false,
   leader = { key = 'Space', mods = mod.META },
   keys = keys,
   key_tables = key_tables,
   mouse_bindings = mouse_bindings,
   quick_select_patterns = quick_select_patterns
}

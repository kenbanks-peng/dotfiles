# Plan: Refactor Sketchybar-AeroSpace Integration Using `aerospace_all_windows`

## Executive Summary

Refactor the sketchybar-aerospace integration to use a single `aerospace list-windows --all` call per event, eliminating redundant subprocess calls and yabai dependencies. This will simplify the codebase, improve performance, and reduce complexity.

## Current Architecture Problems

1. **Excessive subprocess calls**: Each event handler calls `aerospace list-windows` multiple times (once per workspace, once per window for app names)
2. **Yabai dependency**: Uses yabai for window focus detection (`yabai_get_focused_window_id`) and dialog detection (`yabai_is_dialog`) even though aerospace can provide this data
3. **Complex state management**: Functions query aerospace state repeatedly instead of fetching once and passing data down
4. **Redundant data fetching**: Same window data queried multiple times in different functions during single event

## Proposed Architecture

### Core Principle: Fetch Once Per Event

Each event handler will:
1. Call `aerospace_all_windows()` **once** at entry
2. Parse the JSON into usable bash data structures
3. Pass the parsed data to all helper functions
4. Helper functions use the passed data instead of calling aerospace

### Data Structure

`aerospace_all_windows()` will return JSON with all windows and metadata:
```json
[
  {
    "window-id": 12345,
    "app-name": "Cursor",
    "workspace": "1",
    "workspace-is-focused": true
  },
  ...
]
```

From this single JSON response, we can derive:
- All workspaces (unique workspace IDs)
- Focused workspace (where workspace-is-focused=true)
- Windows per workspace (filter by workspace ID)
- App name per window (lookup by window-id)
- Focused window ID (aerospace can tell us via list-windows --focused)

## Implementation Plan

### Phase 1: Core Data Functions

**File: `plugins/helpers/aerospace.sh`**

1. **Complete `aerospace_all_windows()`**
   - Return the full JSON from `aerospace list-windows --all --json`
   - This becomes the single source of truth

2. **Add data accessor functions** that accept JSON as parameter:
   - `aerospace_get_workspaces <json>` - Extract unique workspace IDs
   - `aerospace_get_focused_workspace <json>` - Extract focused workspace
   - `aerospace_get_windows_in_workspace <json> <sid>` - Filter windows by workspace
   - `aerospace_get_appname_by_windowid <json> <window_id>` - Lookup app name
   - `aerospace_get_focused_window_id` - Use `aerospace list-windows --focused --format '%{window-id}'` (single call, no yabai)

3. **Remove yabai dependencies**:
   - Replace `yabai_get_focused_window_id()` with aerospace-based focus detection
   - Remove `yabai_is_dialog()` dependency by using aerospace's window data (dialogs typically don't appear in aerospace's window list or have specific properties)
   - Keep yabai events (window_created, window_destroyed) but validate against aerospace data

### Phase 2: Refactor Event Handlers

**File: `plugins/aerospace_spaces.sh`**

Update each event handler to follow pattern:
```bash
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  # Fetch all data ONCE
  local all_windows=$(aerospace_all_windows)
  local focused_window_id=$(aerospace_get_focused_window_id)

  if [[ "$FOCUS_CHANGE" != "true" ]]; then
    aerospace_workspace_change "$FOCUSED_WORKSPACE" "$PREV_WORKSPACE" "$all_windows"
  fi

  # Handle focus
  local appname=$(aerospace_get_appname_by_windowid "$all_windows" "$focused_window_id")
  if apptype_allow_app "$appname" "$focused_window_id"; then
    aerospace_focused_window_change "$focused_window_id" "$all_windows"
  fi
fi
```

### Phase 3: Refactor Core Functions

**File: `plugins/helpers/aerospace.sh`**

Update these functions to accept `all_windows` JSON parameter:

1. **`aerospace_workspace_change <sid> <prev_sid> <all_windows>`**
   - Extract sticky apps from all_windows
   - Pass all_windows to sub-functions

2. **`aerospace_focused_window_change <window_id> <all_windows>`**
   - Use all_windows to validate window exists
   - Extract workspace from all_windows

3. **`aerospace_add_apps_in_spaceid <sid> <all_windows>`**
   - Extract windows for workspace from all_windows
   - No more repeated aerospace calls

4. **`rebuild_workspaces <all_windows>`**
   - Get all workspace/window data from all_windows
   - Single pass through data

5. **`sync_workspaces <all_windows>`**
   - Compare aerospace workspaces (from all_windows) with sketchybar state

6. **`aerospace_smart_move_window <direction> <all_windows>`**
   - Build current state from all_windows
   - Still needs to call aerospace for actual window moves
   - Re-fetch all_windows after moves complete

7. **`aerospace_swap_workspace <direction> <all_windows>`**
   - Get workspace data from all_windows
   - Re-fetch after swaps complete

### Phase 4: Minimize Yabai Events

**Current yabai events:**
- `yabai_window_created`
- `yabai_window_destroyed`
- `yabai_window_minimized`
- `yabai_window_deminimized`

**Strategy:**
1. Keep these events but make them lightweight validation checks
2. Primary source of truth: aerospace callbacks (exec-on-workspace-change, on-focus-changed)
3. Yabai events become "hints" that trigger aerospace data refresh:

```bash
elif [ "$SENDER" = "yabai_window_created" ]; then
  # Just refresh aerospace state, don't trust yabai data
  local all_windows=$(aerospace_all_windows)
  local focused_sid=$(aerospace_get_focused_workspace "$all_windows")

  # Resync the focused workspace
  aerospace_add_apps_in_spaceid "$focused_sid" "$all_windows"
  sync_workspaces "$all_windows"
fi
```

4. Consider: Can we eliminate yabai events entirely?
   - Test if aerospace's on-focus-changed catches all window creation/destruction
   - If so, remove yabai event subscriptions from `items/aerospace_spaces.sh`
   - This would eliminate yabai dependency completely

### Phase 5: App Type Filtering

**File: `plugins/helpers/app_type.sh`**

1. **Remove yabai dialog detection**:
   - Currently uses `yabai_is_dialog()` to filter dialogs
   - Replace with aerospace-based detection or simpler heuristics
   - Aerospace doesn't manage dialogs/floating windows, so if it's not in aerospace's list, it's filtered

2. **Simplify `apptype_allow_app()`**:
   ```bash
   apptype_allow_app() {
     local appname="$1"
     # Only check excluded apps list
     for excluded in "${EXCLUDED_APPS[@]}"; do
       if [[ "$appname" == "$excluded" ]]; then
         return 1
       fi
     done
     return 0
   }
   ```

3. **Update `apptype_show_sticky_apps()`**:
   - Accept all_windows parameter
   - Extract sticky app windows from all_windows instead of calling aerospace

## Benefits

1. **Performance**: ~90% reduction in subprocess calls per event
   - Before: 10-50 calls to aerospace (depends on workspace/window count)
   - After: 1-2 calls to aerospace per event

2. **Simplicity**:
   - Clear data flow: fetch → parse → pass → use
   - No hidden subprocess calls in helper functions
   - Easier to debug (all data visible at event handler level)

3. **Reduced Dependencies**:
   - Eliminate or minimize yabai dependency
   - Single source of truth (aerospace)

4. **Consistency**:
   - All data from same snapshot
   - No race conditions from multiple queries

5. **Maintainability**:
   - Helper functions become pure data transformations
   - Easy to test (pass in mock JSON)
   - Clear which functions do I/O vs data processing

## Migration Strategy

1. Implement new data accessor functions alongside old ones
2. Refactor one event handler at a time
3. Test each event handler thoroughly
4. Remove old functions once all handlers migrated
5. Test yabai event removal to see if aerospace events are sufficient

## Testing Checklist

- [ ] Workspace switching updates UI correctly
- [ ] Window creation/destruction reflected in UI
- [ ] Window movement between workspaces works
- [ ] Workspace swapping works correctly
- [ ] Smart window movement (next/prev) works
- [ ] Creating new workspace works
- [ ] Sticky apps move correctly
- [ ] Focus highlighting works
- [ ] Excluded apps don't appear
- [ ] Performance improvement measurable (add timing logs)
- [ ] Works without yabai events (if removed)

## Files to Modify

1. `plugins/helpers/aerospace.sh` - Core refactoring
2. `plugins/aerospace_spaces.sh` - Event handler updates
3. `plugins/helpers/app_type.sh` - Remove yabai dependency
4. `items/aerospace_spaces.sh` - Potentially remove yabai event subscriptions
5. `plugins/helpers/yabai.sh` - Mark functions as deprecated or remove

## Risk Mitigation

- Keep backup of working code
- Test on non-primary workspace first
- Add logging to verify data correctness
- Gradual rollout (one event handler at a time)

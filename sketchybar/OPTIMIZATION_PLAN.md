# Optimization Plan: Sketchybar/AeroSpace/Yabai Integration

## Executive Summary

This plan identifies significant performance issues and code duplication across the integration. The primary bottlenecks are:
1. **Repeated subprocess calls** to `sketchybar --query bar` (15+ calls per event)
2. **Redundant `aerospace_all_windows` fetches** despite pass-through pattern
3. **Duplicated configuration arrays** for props/styles
4. **Dead/deprecated code** still present

---

## Part 1: Performance Issues

### 1.1 Excessive `sketchybar --query bar` Calls

**Current State:** Each of these functions makes a separate query:
- `sketchy_add_item()` - line 8
- `sketchy_remove_item()` - line 39
- `sketchy_get_window_items_in_spaceid()` - line 47
- `sketchy_get_item_by_window_id()` - line 54
- `sketchy_highlight_window_id()` - line 111
- `sync_workspaces()` - lines 174, 229, 245
- `aerospace_add_apps_in_spaceid()` - line 394 (inside loop!)
- `aerospace_smart_move_window()` - line 708
- `aerospace_swap_workspace()` - line 853

**Impact:** A single workspace change can trigger 10-20 subprocess calls just for bar queries.

**Solution:** Create a cached bar state passed through the call chain:
```bash
# Fetch once per event
bar_state=$(sketchybar --query bar | jq -r '.items[]')

# Pass to functions
sketchy_add_item "$item" "$location" "$bar_state"
```

### 1.2 Redundant `aerospace_all_windows` Calls

**Current State:** Despite the "use passed or fetch" pattern, several code paths still fetch multiple times:
- `plugins/aerospace_spaces.sh` fetches at lines 38, 70, 86
- `plugins/helpers/aerospace.sh` has fallback fetches at lines 98, 118, 143, 162, 277, 361
- `plugins/helpers/app_type.sh` line 58

**Solution:** Enforce single-fetch at event handler entry, remove fallback fetches.

---

## Part 2: Code Duplication

### 2.1 Props Arrays Defined Multiple Times

**Workspace Divider Props** (identical in 2 places):
- `items/aerospace_spaces.sh` lines 55-65
- `plugins/helpers/aerospace.sh` `sync_workspaces()` lines 183-193

**Window Item Props** (similar in 3 places):
- `aerospace_new_window_id()` lines 300-304
- `aerospace_add_apps_in_spaceid()` lines 364-369
- `aerospace_smart_move_window()` lines 745-749

**Solution:** Define constants in `env.sh` or a new `styles.sh`:
```bash
# env.sh additions
export WORKSPACE_DIVIDER_PROPS=(
  background.padding_left=0
  background.padding_right=0
  background.height=$BACKGROUND_HEIGHT
  background.color=$BAR
  background.corner_radius=0
  width=$WORKSPACE_DIVIDER_WIDTH
  icon.drawing=off
  label.drawing=off
  y_offset=0
)

export WINDOW_ITEM_PROPS=(
  background.corner_radius=0
  icon.font="$ICON_FONT:$ICON_FONTSIZE"
  icon.width="$APP_WIDTH"
)
```

### 2.2 Window Item Creation Logic

**Current:** `aerospace_new_window_id()` and `aerospace_add_apps_in_spaceid()` have overlapping logic for creating window items.

**Solution:** Extract to a single function:
```bash
sketchy_create_window_item() {
  local item="$1"
  local window_id="$2"
  local appname="$3"
  local icon="$4"
  local is_focused="$5"
  local bar_state="$6"  # for existence check
  # ... unified creation logic
}
```

### 2.3 Excluded Apps List Duplicated

**Current:** EXCLUDED_APPS in `app_type.sh` mirrors yabai rules in `yabairc`.

**Solution:** Single source of truth - either:
- Generate yabairc rules from EXCLUDED_APPS, or
- Read from a shared config file

---

## Part 3: Deprecated Code Cleanup

### 3.1 Yabai Helper Functions (`plugins/helpers/yabai.sh`)

**Status:** File header says "DEPRECATED" but still sourced and partially used.

**Still Used:**
- `yabai_is_dialog()` - marked deprecated, but might be called somewhere

**Safe to Remove:**
- `yabai_get_windows_in_space()` - use `aerospace_get_windows_in_workspace()`
- `yabai_get_window_app_name()` - use `aerospace_get_appname_by_windowid()`
- `yabai_get_focused_window_id()` - use `aerospace_get_focused_window_id()`
- `yabai_autofocus()` - not used
- `yabai_is_dialog()` - aerospace doesn't track dialogs

**Action:** Delete entire file after confirming no usage.

### 3.2 Deprecated Functions in `aerospace.sh`

**Marked Deprecated:**
- `aerospace_focused_workspace()` (line 79) - still used by `aerospace_remove_window_id()`
- `aerospace_window_ids_in_workspace()` (line 85) - still used by `aerospace_swap_workspace()`

**Action:** Update callers to use new data accessor pattern, then remove deprecated functions.

---

## Part 4: Architecture Improvements

### 4.1 Yabai's Role

**Current:** Yabai is configured for:
- Float layout (not tiling - aerospace handles that)
- Window signals forwarded to sketchybar

**Question:** Can aerospace's `on-window-detected` replace yabai signals?

**Analysis:**
- `aerospace.toml` has commented `[[on-window-detected]]` config
- AeroSpace provides: `on-focus-changed`, `exec-on-workspace-change`
- AeroSpace does NOT provide: window_created, window_destroyed, window_minimized equivalents

**Conclusion:** Yabai is still needed for window lifecycle signals. But consider if these events are even necessary - they seem to just refresh sketchybar state which could be done on workspace change.

### 4.2 Event Deduplication

**Current:** Lock file mechanism in `plugins/aerospace_spaces.sh` (lines 8-34).

**Issue:** Uses `mkdir` for locking which can leave stale locks on crash.

**Improvement:**
```bash
LOCK_FILE="$CACHE_DIR/aerospace_event.lock"
exec 200>"$LOCK_FILE"
flock -n 200 || exit 0
trap 'flock -u 200' EXIT
```

### 4.3 Source Loop in app_type.sh

**Current:** Line 54 has `source "$PLUGIN_DIR/helpers/aerospace.sh"` with comment "to avoid source loop".

**Issue:** This is a code smell - indicates circular dependencies.

**Solution:** Refactor to eliminate circular sourcing:
1. Move `aerospace_get_window_ids_for_app()` to a lower-level utility
2. Or pass function results instead of sourcing

---

## Part 5: Complexity Reduction

### 5.1 `aerospace_smart_move_window()` - 300+ Lines

**Current:** Handles multiple cases:
- Single vs multiple windows
- Edge vs middle of workspace list
- Ripple operations
- State calculation and application

**Proposed Refactor:**
```bash
# Split into focused functions
_smart_move_calculate_target_workspace()
_smart_move_single_window_ripple()
_smart_move_multi_window_move()
_smart_move_apply_state()
_smart_move_update_sketchybar()
```

### 5.2 `aerospace_swap_workspace()` - 100+ Lines

**Similar pattern:** Could share code with smart_move for:
- Workspace list iteration
- Sketchybar batch updates
- Window item recreation

---

## Part 6: Implementation Priority

### High Priority (Performance)
1. **Cache bar state** - Pass `bar_state` through call chain
2. **Single aerospace fetch** - Remove fallback fetches
3. **Batch sketchybar calls** - Use `sketchybar -m` for multiple operations

### Medium Priority (Maintainability)
4. **Centralize props** - Move to env.sh or styles.sh
5. **Delete yabai.sh** - Remove deprecated file
6. **Fix deprecated function usage** - Update callers

### Low Priority (Architecture)
7. **Refactor smart_move** - Break into smaller functions
8. **Evaluate yabai necessity** - Can we remove window signals?
9. **Fix source loop** - Refactor app_type.sh dependencies

---

## Part 7: Estimated Impact

| Change | Performance Gain | Code Reduction |
|--------|-----------------|----------------|
| Cache bar state | ~50% fewer subprocess calls | ~20 lines |
| Single aerospace fetch | ~20% fewer subprocess calls | ~30 lines |
| Batch sketchybar calls | ~30% faster updates | +10 lines |
| Centralize props | - | ~50 lines |
| Delete yabai.sh | - | ~75 lines |
| Refactor smart_move | Marginal | +50 lines (but cleaner) |

**Total estimated reduction:** ~150 lines of duplicated/dead code
**Performance improvement:** 50-70% fewer subprocess calls per event

---

## Part 8: Testing Strategy

After each change:
1. Switch workspaces rapidly - verify no visual glitches
2. Open/close windows - verify bar updates correctly
3. Use smart_move - verify window moves correctly
4. Check lock file doesn't get stuck
5. Monitor `$CACHE_DIR/aerospace.log` for errors

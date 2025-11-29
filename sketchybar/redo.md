# Sketchybar + AeroSpace Synchronization Architecture Review

## Current Problem

Sketchybar and AeroSpace are frequently getting out of sync. The current architecture has multiple competing mechanisms trying to maintain workspace numbering, leading to race conditions and inconsistent state.

## Core Principle

**AeroSpace is the source of truth. Sketchybar should be a passive observer that reflects AeroSpace's state.**

## Current Architecture Issues

### 1. Multiple Sources of Truth
- **Problem**: The codebase tries to enforce contiguous workspace numbering (1, 2, 3...) in multiple places
- **Scripts involved**:
  - `ensure_contiguous_workspaces.sh` - actively renumbers workspaces
  - `smart_move_window.sh` - tries to create "next" workspace based on calculations
  - `sync_workspaces()` in `aerospace.sh` - syncs Sketchybar items with AeroSpace
  - `aerospace_remove_window_id()` - calls ensure_contiguous after removing windows

### 2. Race Conditions
- **Problem**: `ensure_contiguous_workspaces.sh` runs asynchronously and can renumber workspaces while other scripts are calculating "next" workspace numbers
- **Example from logs**:
  ```
  Current workspace: 3
  Occupied workspaces: 1 3
  Next workspace (contiguous): 3  ← WRONG! ensure_contiguous renamed 3→2 during calculation
  ```
- **Current "fix"**: Added `sleep 0.1` to wait for renumbering - this is fragile and unreliable

### 3. Bidirectional Sync Attempts
- **Problem**: Code tries to both:
  1. Make Sketchybar reflect AeroSpace (correct)
  2. Make AeroSpace conform to Sketchybar's expectations (incorrect)
- The `ensure_contiguous_workspaces.sh` script is trying to force AeroSpace to maintain a specific numbering scheme

### 4. Event Handling Complexity
- **Events being handled**:
  - `exec-on-workspace-change` (from aerospace.toml line 56) → calls `wm workspace_changed`
  - `on-focus-changed` (from aerospace.toml line 63) → triggers `aerospace_workspace_change`
  - `yabai_window_created` → calls `aerospace_new_window_id()`
  - `yabai_window_destroyed` → calls `aerospace_remove_window_id()` → calls `ensure_contiguous_workspaces.sh`
  - `yabai_window_minimized/deminimized`

- **Problem**: These events can fire in rapid succession, causing multiple sync operations to overlap

### 5. Complex Window Movement Logic
- **File**: `smart_move_window.sh`
- **Problem**: Tries to be "smart" about creating workspaces:
  - Ensures contiguous numbering BEFORE moving
  - Calculates "next" workspace based on count
  - Only creates new workspace if multiple windows exist
  - Has special logic for max workspace (9)

- **Why it's problematic**:
  - Assumes workspaces must be contiguous
  - Actively modifies AeroSpace state to enforce this
  - Creates timing dependencies with `sleep 0.1`

## Recommended Architecture

### Core Principles

1. **AeroSpace is Always Right**
   - Never try to renumber or reorganize AeroSpace workspaces
   - Sketchybar displays whatever AeroSpace reports
   - Workspace numbers can have gaps (1, 3, 7) - this is OK

2. **Passive Observation Only**
   - Sketchybar listens to AeroSpace events
   - Sketchybar updates its display to match AeroSpace
   - Sketchybar NEVER tells AeroSpace to reorganize

3. **Single Sync Mechanism**
   - One function: `sync_workspaces()`
   - Called on every relevant event
   - Simple: add missing workspaces, remove empty ones
   - No renumbering, no reorganization

### Proposed Changes

#### 1. Remove Workspace Renumbering
**Delete entirely**:
- `scripts/ensure_contiguous_workspaces.sh`
- All calls to ensure_contiguous_workspaces
- Remove from `aerospace_remove_window_id()` in `aerospace.sh`
- Remove from `smart_move_window.sh`

**Why**: This violates the principle that AeroSpace is the source of truth

#### 2. Simplify Window Movement
**File**: `scripts/smart_move_window.sh`

**Current logic**:
```bash
1. Call ensure_contiguous_workspaces.sh
2. Sleep 0.1
3. Query workspace state
4. Calculate next workspace
5. Move window
```

**Proposed logic**:
```bash
if moving "next":
  if on last occupied workspace AND multiple windows exist:
    # Create new workspace (AeroSpace will assign a number)
    aerospace move-node-to-workspace --no-stdin next
    aerospace workspace --no-stdin next
  else:
    # Use default next behavior
    aerospace move-node-to-workspace --no-stdin next
    aerospace workspace --no-stdin next

if moving "prev":
  aerospace move-node-to-workspace --no-stdin prev
  aerospace workspace --no-stdin prev
```

**Why**:  Let AeroSpace decide workspace numbering. We just move to "next" or "prev"

#### 3. Simplify Workspace Synchronization
**File**: `plugins/helpers/aerospace.sh`
**Function**: `sync_workspaces()`

**Keep current implementation** - it's actually correct:
- Query AeroSpace for all occupied workspaces
- Query Sketchybar for displayed workspaces
- Add Sketchybar items for new workspaces
- Remove Sketchybar items for empty workspaces

**Why**: This is passive observation - correct approach

#### 4. Accept Non-Contiguous Workspace Numbers

**Configuration**: Allow AeroSpace to manage workspace numbers however it wants
- With `persistent-workspaces = []`, workspaces only exist when occupied
- Workspace numbers may have gaps after windows are closed
- This is expected behavior - embrace it

**Sketchybar Display**: Will show whatever AeroSpace has (e.g., workspaces 1, 3, 7)
- Visually this is fine - users will understand
- Workspaces are in numerical order, just with gaps

#### 5. Debounce Event Handling (Optional Improvement)

**Problem**: Multiple events firing rapidly can cause sync to run multiple times
**Solution**: Add simple debouncing to `sync_workspaces()`

```bash
sync_workspaces() {
  local current_time=$(get_timestamp)
  local last_sync_time

  if [ -f "$CACHE_DIR/last_sync_time" ]; then
    read -r last_sync_time <"$CACHE_DIR/last_sync_time"
    local diff=$(diff_time "$current_time" "$last_sync_time")

    # If last sync was < 50ms ago, skip this one
    if [ "$diff" -lt 50 ]; then
      return
    fi
  fi

  echo "$current_time" >"$CACHE_DIR/last_sync_time"

  # ... existing sync_workspaces logic ...
}
```

### Files to Modify

1. **DELETE**:
   - `/Users/kenbanks/Software/Public/dotfiles/sketchybar/scripts/ensure_contiguous_workspaces.sh`

2. **MODIFY**:
   - `/Users/kenbanks/Software/Public/dotfiles/sketchybar/scripts/smart_move_window.sh`
     - Remove ensure_contiguous_workspaces call
     - Remove sleep 0.1
     - Simplify to use AeroSpace's next/prev without calculating workspace numbers
     - Remove workspace counting logic
     - Remove max workspace (9) check

   - `/Users/kenbanks/Software/Public/dotfiles/sketchybar/plugins/helpers/aerospace.sh`
     - Remove ensure_contiguous_workspaces call from `aerospace_remove_window_id()`
     - Keep `sync_workspaces()` as-is (it's correct)
     - Optionally add debouncing to `sync_workspaces()`

3. **KEEP AS-IS**:
   - `/Users/kenbanks/Software/Public/dotfiles/sketchybar/items/aerospace_spaces.sh` - initialization is fine
   - `/Users/kenbanks/Software/Public/dotfiles/sketchybar/plugins/aerospace_spaces.sh` - event routing is fine
   - `/Users/kenbanks/Software/Public/dotfiles/sketchybar/plugins/helpers/sketchy.sh` - helper functions are fine
   - `/Users/kenbanks/Software/Public/dotfiles/sketchybar/scripts/new_workspace.sh` - Alt-0 behavior is fine

## Testing Plan

After implementing changes:

1. **Test window creation**: Open multiple windows, verify Sketchybar shows all windows
2. **Test window destruction**: Close windows, verify Sketchybar removes them and removes empty workspaces
3. **Test workspace navigation**: Use Alt-Left/Right to navigate, verify highlighting works
4. **Test smart window movement**:
   - Move window right on last workspace with multiple windows → creates new workspace
   - Move window right on last workspace with single window → does nothing
5. **Test rapid operations**: Quickly open/close windows, move windows, verify no sync issues
6. **Test gaps in numbering**: Manually create workspaces 1, 3, 5 and verify Sketchybar displays them correctly

## Expected Behavior After Changes

1. **Workspace numbers may have gaps** - this is OK and expected
2. **No more race conditions** - no competing numbering mechanisms
3. **Faster operations** - no sleep delays
4. **Simpler codebase** - less logic, fewer files
5. **AeroSpace is authoritative** - Sketchybar always reflects AeroSpace's state accurately

## Migration Notes

- User might see workspace numbers like "1, 3, 7" instead of "1, 2, 3"
- This is the correct behavior with `persistent-workspaces = []`
- If user wants contiguous numbering, they can manually use Alt-1, Alt-2, Alt-3 to create workspaces in order
- Or they can add back persistent-workspaces: `persistent-workspaces = [1, 2, 3, 4, 5]`

## Questions to Address

1. **Do we actually need contiguous workspace numbering?**
   - NO - this is an artificial constraint we've imposed
   - AeroSpace works fine with gaps
   - User can see which workspaces are occupied

2. **What should happen when creating a "new" workspace?**
   - Let AeroSpace decide the number (use `next`)
   - Don't try to calculate or predict
   - If AeroSpace decides workspace 7 is "next" after workspace 3, trust it

3. **How to handle Alt-0 (create new workspace)?**
   - Current implementation queries last workspace and adds 1
   - Problem: This assumes contiguous numbering
   - Solution: Just use `aerospace workspace next` or let AeroSpace pick the number
   - Alternative: Keep current behavior but don't enforce it elsewhere

4. **Should we keep the "multiple windows" check for creating new workspace?**
   - YES - this is a UX improvement, not architectural issue
   - Only creates new workspace if current has multiple windows
   - This prevents accidentally creating empty workspaces

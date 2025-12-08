# Aerospace JSON Refactor Plan

## Status: COMPLETED

## Goal
Simplify aerospace shell scripts by leveraging `--json` format more consistently, reducing bash array manipulation and shell loops.

## Changes Implemented

### New Helper Functions Added

```bash
# Get workspace list as JSON
aerospace_list_workspaces_json()

# Get sorted workspace IDs from JSON
aerospace_get_workspace_ids_sorted()

# Find adjacent workspace (next/prev)
aerospace_adjacent_workspace()

# Set operations for workspace sync
aerospace_workspaces_to_add()
aerospace_workspaces_to_remove()
aerospace_next_existing_workspace()
```

### Functions Refactored

1. **`aerospace_workspace_next()`** - Reduced from 35 lines to 12 lines
   - Now uses `aerospace_adjacent_workspace()` helper

2. **`aerospace_create_new_workspace()`** - Simplified workspace list handling
   - Uses `aerospace_list_workspaces_json()` with jq

3. **`sync_workspaces()`** - Eliminated manual array diff logic
   - Uses `aerospace_workspaces_to_add()` and `aerospace_workspaces_to_remove()`
   - Uses `aerospace_next_existing_workspace()` for positioning

4. **`aerospace_swap_workspace()`** - Simplified workspace finding
   - Uses `aerospace_adjacent_workspace()` instead of manual index calculation

5. **`aerospace_smart_move_window()`** - Simplified initial data fetching
   - Uses `aerospace_list_workspaces_json()` and `aerospace_get_workspace_ids_sorted()`
   - Uses `aerospace_get_windows_in_workspace()` from cached all_windows
   - State machine logic preserved (inherently complex)

## Benefits

- **Reduced code duplication**: Common patterns extracted to reusable helpers
- **Better data locality**: Fetch data once, pass to helpers
- **Clearer intent**: `aerospace_adjacent_workspace()` is more readable than index math
- **Set operations in jq**: More efficient than bash array iteration for diff operations

## Testing Results

- All helper functions tested and working
- Sketchybar refresh (`aerospace_workspace_change SENDER=forced`) works correctly
- Workspace items display in correct order

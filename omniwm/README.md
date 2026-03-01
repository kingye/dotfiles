# OmniWM Configuration

This directory contains the configuration for OmniWM, a window manager for macOS.

## Default Layout

- **Layout Type**: Niri (scrollable tiling)
- **Gap Size**: 8px
- **Border Width**: 2px
- **Border Color**: Cyan/Teal
- **Borders Enabled**: Yes
- **Focus Follows Mouse**: No

## Niri Layout Settings

- **Always Center Single Column**: Yes
- **Center Focused Column**: On Overflow
- **Infinite Loop**: Yes (allows wrapping when navigating)
- **Max Visible Columns**: 2
- **Max Windows Per Column**: 3
- **Column Width Presets**: 33%, 50%, 67%

## Keybindings

### Keybinding Design Philosophy

The keybindings follow a consistent and logical pattern:

**Modifier System:**

- **`Opt`** (⌥) - Primary modifier for all window manager operations
- **`Opt+Shift`** - Moves or relocates (windows, columns, workspaces)
- **`Opt+Ctrl`** - Direct access to numbered items (columns by index)
- **`Opt+Ctrl+Shift`** - Advanced operations (moving workspaces between monitors)

**Key Grouping Logic:**

- **Numbers (1-9)** - Workspace selection and movement
- **HJKL** - Vim-style directional navigation (Left/Down/Up/Right)
- **Brackets `[` `]`** - Column operations (navigation and movement)
- **Comma/Period `,` `.`** - Monitor operations (think `<` `>` for previous/next)
- **Letters** - Mnemonic actions:
  - `S` = Search/Show all windows (finder)
  - `G` = Go to top/bottom of column
  - `C` = Column (first/last)
  - `F` = Full width toggle
  - `Z` = Fullscreen (maxi*Z*e)
  - `W` = Width cycling
  - `B` = Balance sizes
  - `I/O` = In/Out (consume/expel windows in columns)
  - `T` = Tabbed mode toggle
  - `P` = Previous window
  - `M` = Menu
  - `V` = View (overview)
  - `R` = Rotate/toggle layout

**Operation Pattern:**

- **Base key** - Focus/navigate to target
- **Base + Shift** - Move/relocate to target
- **Base + Ctrl** - Direct selection by number
- **Base + Ctrl + Shift** - Advanced relocation operations

### Modifiers Key Reference

- `Opt` = Option key (⌥) - Modifier: 2048
- `Opt+Shift` = Option + Shift (⌥⇧) - Modifier: 2560
- `Opt+Ctrl` = Option + Control (⌥⌃) - Modifier: 6144
- `Opt+Ctrl+Shift` = Option + Control + Shift (⌥⌃⇧) - Modifier: 6656

### Workspace Management

| Keybinding | Action |
|------------|--------|
| `Opt+1` | Switch to workspace 1 |
| `Opt+2` | Switch to workspace 2 |
| `Opt+3` | Switch to workspace 3 |
| `Opt+4` | Switch to workspace 4 |
| `Opt+5` | Switch to workspace 5 |
| `Opt+6` | Switch to workspace 6 |
| `Opt+7` | Switch to workspace 7 |
| `Opt+8` | Switch to workspace 8 |
| `Opt+9` | Switch to workspace 9 |
| `Opt+Shift+1` | Move window to workspace 1 |
| `Opt+Shift+2` | Move window to workspace 2 |
| `Opt+Shift+3` | Move window to workspace 3 |
| `Opt+Shift+4` | Move window to workspace 4 |
| `Opt+Shift+5` | Move window to workspace 5 |
| `Opt+Shift+6` | Move window to workspace 6 |
| `Opt+Shift+7` | Move window to workspace 7 |
| `Opt+Shift+8` | Move window to workspace 8 |
| `Opt+Shift+9` | Move window to workspace 9 |
| `Opt+R` | Toggle workspace layout |

### Window Focus

| Keybinding | Action |
|------------|--------|
| `Opt+H` | Focus left window |
| `Opt+J` | Focus down window |
| `Opt+K` | Focus up window |
| `Opt+L` | Focus right window |
| `Opt+P` | Focus previous window |
| `Opt+[` | Focus down or left |
| `Opt+]` | Focus up or right |
| `Opt+G` | Focus top window in column |
| `Opt+Shift+G` | Focus bottom window in column |
| `Opt+C` | Focus first column |
| `Opt+Shift+C` | Focus last column |

### Window Movement

| Keybinding | Action |
|------------|--------|
| `Opt+Shift+H` | Move window left |
| `Opt+Shift+J` | Move window down |
| `Opt+Shift+K` | Move window up |
| `Opt+Shift+L` | Move window right |
| `Opt+Shift+[` | Move column left |
| `Opt+Shift+]` | Move column right |

### Window Grouping (Columns)

| Keybinding | Action |
|------------|--------|
| `Opt+I` | Consume window from left (merge into column) |
| `Opt+Shift+I` | Consume window from right |
| `Opt+O` | Expel window to left (split from column) |
| `Opt+Shift+O` | Expel window to right |
| `Opt+T` | Toggle column tabbed mode |

### Column Focus by Number

| Keybinding | Action |
|------------|--------|
| `Opt+Ctrl+1` | Focus column 1 |
| `Opt+Ctrl+2` | Focus column 2 |
| `Opt+Ctrl+3` | Focus column 3 |
| `Opt+Ctrl+4` | Focus column 4 |
| `Opt+Ctrl+5` | Focus column 5 |
| `Opt+Ctrl+6` | Focus column 6 |
| `Opt+Ctrl+7` | Focus column 7 |
| `Opt+Ctrl+8` | Focus column 8 |
| `Opt+Ctrl+9` | Focus column 9 |

### Window Sizing

| Keybinding | Action |
|------------|--------|
| `Opt+W` | Cycle column width forward (33% → 50% → 67%) |
| `Opt+Shift+W` | Cycle column width backward |
| `Opt+F` | Toggle column full width |
| `Opt+B` | Balance all window sizes |

### Fullscreen

| Keybinding | Action |
|------------|--------|
| `Opt+Z` | Toggle fullscreen (OmniWM managed) |
| `Opt+Shift+Z` | Toggle native macOS fullscreen |

### Monitor Management

| Keybinding | Action |
|------------|--------|
| `Opt+,` | Focus previous monitor |
| `Opt+.` | Focus next monitor |
| `Opt+Shift+,` | Move window to monitor up |
| `Opt+Shift+.` | Move window to monitor down |
| `Opt+Ctrl+Shift+,` | Move workspace to monitor up |
| `Opt+Ctrl+Shift+.` | Move workspace to monitor down |
| `Opt+Ctrl+Shift+1` | Summon workspace 1 to current monitor |
| `Opt+Ctrl+Shift+2` | Summon workspace 2 to current monitor |
| `Opt+Ctrl+Shift+3` | Summon workspace 3 to current monitor |
| `Opt+Ctrl+Shift+4` | Summon workspace 4 to current monitor |
| `Opt+Ctrl+Shift+5` | Summon workspace 5 to current monitor |
| `Opt+Ctrl+Shift+6` | Summon workspace 6 to current monitor |
| `Opt+Ctrl+Shift+7` | Summon workspace 7 to current monitor |
| `Opt+Ctrl+Shift+8` | Summon workspace 8 to current monitor |
| `Opt+Ctrl+Shift+9` | Summon workspace 9 to current monitor |

### Menu & Utilities

| Keybinding | Action |
|------------|--------|
| `Opt+S` | Open window finder |
| `Opt+M` | Open menu anywhere (at cursor) |
| `Opt+Shift+M` | Open menu palette (centered) |
| `Opt+V` | Toggle overview mode |

## Workspace Bar

- **Position**: Overlapping menu bar
- **Height**: 24px
- **Background Opacity**: 10%
- **Show Labels**: Yes
- **Show App Icons**: Yes (deduplicated)
- **Window Level**: Popup

## Gestures

- **Enabled**: Yes
- **Finger Count**: 3 fingers
- **Invert Direction**: Yes
- **Scroll Modifier**: Option+Shift
- **Scroll Sensitivity**: 1.0

## Mouse Settings

- **Mouse Warp**: Enabled
- **Mouse Warp Margin**: 2px
- **Move Mouse to Focused Window**: No

## macOS Virtual Key Code Reference

### Letters

| KeyCode | Key | KeyCode | Key | KeyCode | Key | KeyCode | Key |
|---------|-----|---------|-----|---------|-----|---------|-----|
| 0 | A | 11 | B | 8 | C | 2 | D |
| 14 | E | 3 | F | 5 | G | 4 | H |
| 34 | I | 38 | J | 40 | K | 37 | L |
| 46 | M | 45 | N | 31 | O | 35 | P |
| 12 | Q | 15 | R | 1 | S | 17 | T |
| 32 | U | 9 | V | 13 | W | 7 | X |
| 16 | Y | 6 | Z | | | | |

### Numbers

| KeyCode | Key | KeyCode | Key | KeyCode | Key | KeyCode | Key |
|---------|-----|---------|-----|---------|-----|---------|-----|
| 18 | 1 | 19 | 2 | 20 | 3 | 21 | 4 |
| 23 | 5 | 22 | 6 | 26 | 7 | 28 | 8 |
| 25 | 9 | 29 | 0 | | | | |

### Special Characters

| KeyCode | Key | KeyCode | Key | KeyCode | Key | KeyCode | Key |
|---------|-----|---------|-----|---------|-----|---------|-----|
| 33 | [ | 30 | ] | 43 | , | 47 | . |
| 27 | - | 24 | = | 41 | ; | 39 | ' |
| 44 | / | 42 | \\ | 50 | ` | | |

### Other Keys

| KeyCode | Key | KeyCode | Key | KeyCode | Key | KeyCode | Key |
|---------|-----|---------|-----|---------|-----|---------|-----|
| 36 | Return | 48 | Tab | 49 | Space | 51 | Delete |
| 53 | Escape | | | | | | |

### Modifier Values

| Modifier | Value | | | | | | |
|----------|-------|---|---|---|---|---|---|
| Option (⌥) | 2048 | | | | | | |
| Option + Shift | 2560 | | | | | | |
| Option + Control | 6144 | | | | | | |
| Option + Control + Shift | 6656 | | | | | | |

### Special Value

- **4294967295** with modifier **0** = Unbound keybinding

## Notes

- The default modifier key for most operations is `Opt` (⌥ Option)
- Workspace numbering uses the number keys 1-9
- The Niri layout is a scrollable tiling layout that allows for flexible column-based window arrangement
- Column-based window management allows grouping multiple windows in the same vertical space (tabbed or stacked)
- Use `Opt+I` and `Opt+O` to merge and split windows into/from columns
- Use `Opt+T` to toggle between tabbed and stacked views within a column

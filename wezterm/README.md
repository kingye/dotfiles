# WezTerm Configuration

Modern GPU-accelerated terminal emulator with extensive Lua-based configuration.

## Features

- Custom keybindings with tmux-style leader key
- Smart Neovim + WezTerm navigation integration
- Window and tab management
- Pane splitting and navigation
- Custom status line and tab bar
- Dynamic backdrop images
- Font customization

## Leader Key

The leader key is `Ctrl+s`. Press this combination first, then the command key within 5 seconds.

## Keybinding Design Philosophy

The keybindings follow a tmux-inspired pattern with logical improvements:

**Leader Key System:**
- **`Leader`** (`Ctrl+s`) - Primary prefix for all terminal multiplexing operations
- **Timeout**: 5 seconds to press the command key after leader

**Key Grouping Logic:**
- **Pane Splits** - Visual characters (tmux-compatible):
  - `"` = Vertical split (looks like vertical divider)
  - `%` = Horizontal split (horizontal line through %)
- **Navigation** - Improved directional logic:
  - `Ctrl+h/j/k/l` = Navigate between panes (smart Neovim integration)
  - **Tabs**: `Leader` + `[` / `]` = Previous/Next tab (think: sequential order)
  - **Windows**: `Leader` + `,` / `.` = Previous/Next window (think: `<` / `>` for navigation)
  - *Note: Standard tmux uses `n`/`p` for next/previous window*
- **Pane Resize** - Two modes:
  - `Ctrl+Shift+h/j/k/l` = Quick resize (10 cells)
  - `Leader` + `p` then `h/j/k/l` = Continuous resize mode
- **Tab Movement** - Curly braces for reordering:
  - `Leader` + `{` = Move tab left
  - `Leader` + `}` = Move tab right
- **Numbers `0-9`** - Direct window access (tmux-compatible)
- **Letters** - Mnemonic actions (mostly tmux-compatible):
  - `c` = Create new tab (tmux: new window)
  - `w` = New window
  - `s` = Show launcher (search)
  - `m` = Move/swap pane (keep focus)
  - `o/O` = Rotate panes (clockwise/counter-clockwise)
  - `z` = Zoom/maximize pane
  - `x` = Close pane with confirmation
  - `&` = Close tab without confirmation (tmux: kill window)
  - `y` = Yank mode (copy mode)
  - `f` = Font resize mode (enters key table)
  - `p` = Pane resize mode (enters key table)
- **Space** = Pane selection UI (interactive)
- **Font Resizing** - Two approaches:
  - `Ctrl+Shift+` `+`/`-`/`r` = Direct font size adjust/reset
  - `Leader` + `f` then `+`/`-`/`r` = Key table mode for continuous resizing

**Operation Pattern:**
- **Leader + action** - Single command execution
- **Leader + mode key** - Enter key table for continuous operations (font resize, pane resize)
- **Ctrl + key** - Direct actions without leader (navigation, scrolling)
- **Ctrl + Shift + key** - Quick resize and scrolling operations

## Keybindings

### Pane Management

| Keybinding | Action | tmux |
|------------|--------|------|
| `Leader` + `"` | Split pane vertically | `Prefix` + `"` |
| `Leader` + `%` | Split pane horizontally | `Prefix` + `%` |
| `Ctrl+h/j/k/l` | Navigate panes (smart: passes through to Neovim if active) | `Prefix` + arrow keys |
| `Ctrl+Shift+h/j/k/l` | Resize pane in direction (10 cells) | `Prefix` + `Ctrl+arrow` |
| `Leader` + `Space` | Pane selection UI (swap with active, follow focus) | Similar to `Prefix` + `q` |
| `Leader` + `m` | Pane selection UI (swap with active, keep focus) | - |
| `Leader` + `o` | Rotate panes clockwise | `Prefix` + `o` |
| `Leader` + `O` | Rotate panes counter-clockwise | `Prefix` + `Ctrl+o` |
| `Leader` + `z` | Toggle pane zoom (maximize/restore) | `Prefix` + `z` |
| `Leader` + `x` | Close current pane (with confirmation) | `Prefix` + `x` |

### Window Management

| Keybinding | Action | tmux |
|------------|--------|------|
| `Leader` + `w` | Spawn new window | - |
| `Leader` + `0-9` | Switch to window by number (0-9) | `Prefix` + `0-9` |
| `Leader` + `,` | Previous window | `Prefix` + `p` |
| `Leader` + `.` | Next window | `Prefix` + `n` |

### Tab Management

| Keybinding | Action | tmux |
|------------|--------|------|
| `Leader` + `c` | Create new tab | `Prefix` + `c` |
| `Leader` + `[` | Previous tab | - |
| `Leader` + `]` | Next tab | - |
| `Leader` + `{` | Move tab left | - |
| `Leader` + `}` | Move tab right | - |
| `Leader` + `&` | Close current tab (no confirmation) | `Prefix` + `&` |

### Font Size

| Keybinding | Action | tmux |
|------------|--------|------|
| `Ctrl+Shift++` | Increase font size | - |
| `Ctrl+Shift+-` | Decrease font size | - |
| `Ctrl+Shift+r` | Reset font size | - |
| `Leader` + `f` then `+` | Increase font size (key table mode) | - |
| `Leader` + `f` then `-` | Decrease font size (key table mode) | - |
| `Leader` + `f` then `r` | Reset font size (key table mode) | - |
| `Leader` + `f` then `Escape/q` | Exit font resize mode | - |

### Pane Resizing (Key Table Mode)

| Keybinding | Action | tmux |
|------------|--------|------|
| `Leader` + `p` | Enter pane resize mode | - |
| `h/j/k/l` | Resize in direction (while in mode) | - |
| `Escape/q` | Exit pane resize mode | - |

### Scrolling

| Keybinding | Action | tmux |
|------------|--------|------|
| `Ctrl+Shift+f` | Scroll forward one page | - |
| `Ctrl+Shift+b` | Scroll backward one page | - |
| `Ctrl+Shift+u` | Scroll up half page | - |
| `Ctrl+Shift+d` | Scroll down half page | - |

### Other

| Keybinding | Action | tmux |
|------------|--------|------|
| `Leader` + `s` | Show launcher (list windows/tabs/panes) | `Prefix` + `w` (choose-tree) |
| `Leader` + `y` | Activate copy mode | `Prefix` + `[` |

## Configuration Structure

```
wezterm/
├── wezterm.lua           # Main entry point
├── config/
│   ├── appearance.lua    # Colors and visual settings
│   ├── bindings.lua      # Keybindings configuration
│   ├── domains.lua       # SSH and multiplexing domains
│   ├── fonts.lua         # Font configuration
│   └── general.lua       # General settings
├── events/
│   ├── gui-startup.lua   # Window startup behavior
│   ├── left-status.lua   # Left status line
│   ├── right-status.lua  # Right status line
│   ├── tab-title.lua     # Tab title formatting
│   └── new-tab-button.lua
└── utils/
    └── backdrops.lua     # Background image management
```

## Smart Navigation

The `Ctrl+h/j/k/l` keybindings are "smart" - they detect if Neovim is running in the current pane:
- If Neovim is active: the keys are passed through to Neovim for split navigation
- If Neovim is not active: the keys control WezTerm pane navigation

This seamless integration allows consistent navigation between Neovim splits and WezTerm panes.

## Installation

1. Install WezTerm:
   ```bash
   brew install wezterm
   ```

2. Link configuration:
   ```bash
   ln -s ~/dotfiles/wezterm ~/.config/wezterm
   ```

3. Reload WezTerm or restart the application

## Customization

- **Leader key**: Modify in `config/bindings.lua` (line 24)
- **Colors**: Edit `config/appearance.lua`
- **Fonts**: Edit `config/fonts.lua`
- **Background images**: Configure in `utils/backdrops.lua`

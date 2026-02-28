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

## Keybindings

### Pane Management

| Keybinding | Action |
|------------|--------|
| `Leader` + `"` | Split pane vertically |
| `Leader` + `%` | Split pane horizontally |
| `Ctrl+h/j/k/l` | Navigate panes (smart: passes through to Neovim if active) |
| `Ctrl+Shift+h/j/k/l` | Resize pane in direction (10 cells) |
| `Leader` + `Space` | Pane selection UI (swap with active, follow focus) |
| `Leader` + `m` | Pane selection UI (swap with active, keep focus) |
| `Leader` + `o` | Rotate panes clockwise |
| `Leader` + `O` | Rotate panes counter-clockwise |
| `Leader` + `z` | Toggle pane zoom (maximize/restore) |
| `Leader` + `x` | Close current pane (with confirmation) |

### Window Management

| Keybinding | Action |
|------------|--------|
| `Leader` + `w` | Spawn new window |
| `Leader` + `0-9` | Switch to window by number (0-9) |
| `Leader` + `j` | Next window |
| `Leader` + `k` | Previous window |

### Tab Management

| Keybinding | Action |
|------------|--------|
| `Leader` + `c` | Create new tab |
| `Leader` + `h` | Previous tab |
| `Leader` + `l` | Next tab |
| `Leader` + `[` | Move tab left |
| `Leader` + `]` | Move tab right |
| `Leader` + `&` | Close current tab (no confirmation) |

### Font Size

| Keybinding | Action |
|------------|--------|
| `Ctrl+Shift++` | Increase font size |
| `Ctrl+Shift+-` | Decrease font size |
| `Ctrl+Shift+r` | Reset font size |
| `Leader` + `f` then `+` | Increase font size (key table mode) |
| `Leader` + `f` then `-` | Decrease font size (key table mode) |
| `Leader` + `f` then `r` | Reset font size (key table mode) |
| `Leader` + `f` then `Escape/q` | Exit font resize mode |

### Pane Resizing (Key Table Mode)

| Keybinding | Action |
|------------|--------|
| `Leader` + `p` | Enter pane resize mode |
| `h/j/k/l` | Resize in direction (while in mode) |
| `Escape/q` | Exit pane resize mode |

### Scrolling

| Keybinding | Action |
|------------|--------|
| `Ctrl+Shift+f` | Scroll forward one page |
| `Ctrl+Shift+b` | Scroll backward one page |
| `Ctrl+Shift+u` | Scroll up half page |
| `Ctrl+Shift+d` | Scroll down half page |

### Other

| Keybinding | Action |
|------------|--------|
| `Leader` + `s` | Show launcher (list windows/tabs/panes) |
| `Leader` + `y` | Activate copy mode |

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

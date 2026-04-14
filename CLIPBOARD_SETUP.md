# Neovim Clipboard Setup for macOS and Linux Cloud

## Overview
This configuration provides intelligent clipboard support that works on both macOS and Linux cloud instances with Tmux.

## Features
- **macOS**: Uses native `pbcopy`/`pbpaste`
- **Linux Cloud + Tmux**: Uses OSC52 protocol over SSH (via WezTerm)
- **Linux Cloud + Tmux (no OSC52)**: Falls back to Tmux buffer
- **Same config**: Works identically on both systems

## Files Modified
1. `nvim/lua/config/clipboard.lua` - Intelligent clipboard configuration
2. `nvim/lua/plugins/clipboard.lua` - Optional OSC52 plugin (lazy-loaded)
3. `nvim/init.lua` - Added clipboard setup call
4. `nvim/lua/config/keymaps.lua` - Added clipboard keymaps

## Keymaps

### Universal (works everywhere)
- `<leader>y` - Yank to system clipboard
- `<leader>p` - Paste from system clipboard
- `<leader>p` (visual mode) - Paste and replace selection

### Tmux-specific (only when in Tmux)
- `<leader>yt` - Yank to Tmux buffer (for intra-instance copying)
- `<leader>pt` - Paste from Tmux buffer

## How It Works

### On macOS
1. Detects macOS via `vim.fn.has('mac')`
2. Sets `clipboard=unnamedplus`
3. Uses native `pbcopy`/`pbpaste`

### On Linux Cloud with Tmux
1. Detects Linux and Tmux environment
2. Checks if terminal supports OSC52 (WezTerm, iTerm2, xterm)
3. If OSC52 supported:
   - Uses `ojroques/nvim-osc52` plugin
   - Works over SSH without X11 forwarding
4. If OSC52 not supported:
   - Falls back to Tmux buffer
   - Works within the cloud instance only

## Testing

### On macOS
```bash
# Test clipboard detection
nvim -c 'lua require("config.clipboard").setup()' -c 'set clipboard?' -c 'qa!'

# Test keymaps
nvim -c 'lua require("config.clipboard").setup_keymaps()' -c 'map <leader>y' -c 'qa!'
```

### On Linux Cloud
```bash
# Verify clipboard works over SSH
# 1. Yank text in Neovim: `yy`
# 2. Paste locally: Cmd+V (macOS) or Ctrl+V (Linux)

# Verify Tmux buffer works
# 1. Yank to Tmux buffer: `<leader>yt`
# 2. Paste in another Neovim: `<leader>pt`
```

## Notes
- OSC52 requires terminal support (WezTerm has excellent OSC52 support)
- Tmux must be running for Tmux buffer integration
- No X11 forwarding or external clipboard tools needed
- Configuration is identical on both systems
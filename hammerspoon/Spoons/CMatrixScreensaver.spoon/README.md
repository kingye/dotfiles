# CMatrixScreensaver

A Hammerspoon Spoon that creates a cmatrix screensaver using Alacritty terminal.

## Features

- ✅ Automatic activation after configurable idle time (default: 15 minutes)
- ✅ Manual activation via hotkey (default: Cmd+Shift+S)
- ✅ Fullscreen cmatrix effect in Alacritty terminal
- ✅ Minimal UI (no scrollbars)
- ✅ Manual stop with Ctrl+C (simplified, no automatic activity detection)

## Installation

1. Ensure you have cmatrix installed:

```bash
brew install cmatrix
```

2. Ensure you have Alacritty installed:

```bash
brew install --cask alacritty
```

3. Copy the CMatrixScreensaver.spoon folder to `~/.hammerspoon/Spoons/`

4. Add to your `~/.hammerspoon/init.lua`:

```lua
CMatrixScreensaver = hs.loadSpoon("CMatrixScreensaver")
CMatrixScreensaver.idleTimeout = 900  -- 15 minutes in seconds
CMatrixScreensaver:bindHotkeys({
  trigger = {{"cmd", "shift"}, "s"}
})
CMatrixScreensaver:start()
```

## Configuration

### CMatrixScreensaver.idleTimeout

Idle timeout in seconds before screensaver activates (default: 900 = 15 minutes)

### CMatrixScreensaver.cmatrixArgs

Additional arguments to pass to cmatrix (default: "")

Example:

```lua
CMatrixScreensaver.cmatrixArgs = "-b -C blue"  -- Bold mode with blue color
```

## Usage

### Manual Activation

Press **Cmd+Shift+S** (or your configured hotkey)

### Automatic Activation

Wait for the configured idle time (default: 15 minutes)

### Deactivation

Press **Ctrl+C** in the terminal to stop cmatrix, then **Cmd+W** to close the window.

**Note**: This version uses manual stop only. There is no automatic activity detection that closes the screensaver.

## How It Works

1. When triggered, a wrapper script is created at `/tmp/cmatrix_wrapper.sh`
2. Alacritty launches with this script, which runs cmatrix
3. The window automatically goes fullscreen
4. You manually stop cmatrix with Ctrl+C when you want to exit

## Stopping the Screensaver

To exit the screensaver:

1. Press **Ctrl+C** to stop cmatrix
2. Press **Cmd+W** to close the Alacritty window

## Technical Details

- Uses Alacritty terminal for minimal UI
- Creates wrapper script to keep terminal alive after cmatrix exits
- Hardcoded cmatrix path: `/opt/homebrew/bin/cmatrix`
- No automatic activity detection - manual stop only with Ctrl+C
- Simplified design for reliability

## License

MIT

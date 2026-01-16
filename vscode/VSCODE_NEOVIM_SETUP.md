# VSCode-Neovim Setup Guide

This guide explains how your VSCode Neovim integration works and how to troubleshoot common issues.

## Architecture Overview

Your VSCode setup uses **vscode-neovim extension**, which directly integrates your actual Neovim instance into VSCode. This is different from VSCodeVim (a separate Vim emulator).

### Dual Configuration System

Your keybindings are split between two configuration files:

1. **Neovim Config** (`~/.config/nvim/lua/config/keymaps.lua`)

   - Contains all leader key mappings (`Space + ...`)
   - Activated when `vim.g.vscode == true`
   - Works in editor when in Vim modes (Normal, Insert, Visual)
   - Single source of truth - changes here apply to both Neovim and VSCode

2. **VSCode Keybindings** (`keybindings.json`)
   - Contains enhanced Vim behavior (centered search, line movement, etc.)
   - Handles sidebar-specific mappings
   - Provides window navigation with `Ctrl+h/j/k/l`
   - Works in non-editor contexts (sidebars, panels, search results)

### Why This Approach?

**Neovim config handles:**

- Leader key mappings (Space-based commands)
- Editor-focused actions
- Consistency between Neovim and VSCode

**VSCode keybindings handle:**

- Native VSCode integrations
- Sidebar and panel navigation
- Enhanced Vim motions that work better as native keybindings

## How It Works

```
VSCode starts
    ↓
vscode-neovim extension loads
    ↓
Reads: /opt/homebrew/bin/nvim
    ↓
Loads: ~/.config/nvim/init.lua
    ↓
Sets: vim.g.vscode = true
    ↓
Activates: VSCode-specific keymaps in keymaps.lua
    ↓
Leader key mappings available via vscode.action() API
    ↓
Native keybindings.json provides complementary bindings
```

## Configuration Files

### settings.json

```json
{
  "vscode-neovim.neovimExecutablePaths.darwin": "/opt/homebrew/bin/nvim",
  "vscode-neovim.neovimInitVimPaths.darwin": "$HOME/.config/nvim/init.lua",
  "vscode-neovim.compositeKeys": {
    "jk": {
      "command": "vscode-neovim.escape"
    }
  }
}
```

### keymaps.lua (VSCode Section)

```lua
if vim.g.vscode then
  local vscode = require('vscode')

  -- All your leader key mappings
  map('n', '<leader>ff', function() vscode.action('workbench.action.quickOpen') end, { desc = 'Find files' })
  -- ... and many more
end
```

### keybindings.json

```json
[
  // Enhanced Vim behavior
  {
    "key": "j",
    "command": "extension.vim_escape",
    "when": "editorTextFocus && vim.active && vim.mode == 'Insert'"
  },

  // Window navigation
  {
    "key": "ctrl+h",
    "command": "workbench.action.navigateLeft",
    "when": "vim.active && !suggestWidgetVisible"
  },

  // Sidebar navigation
  {
    "key": "space e",
    "command": "workbench.view.explorer",
    "when": "sideBarFocus && !inputFocus"
  }
]
```

## Testing Your Setup

### 1. Verify vscode-neovim is Active

Open VSCode and check:

- **Extensions**: Search for "Neo Vim" by asvetliakov (should be installed and enabled)
- **Output Panel**: `Cmd+Shift+U` → Select "Neovim" → Look for initialization messages

### 2. Test Leader Key Mappings

In any file:

1. Press `Esc` to enter Normal mode
2. Try these commands:
   - `Space f f` → Should open Quick Open
   - `Space e` → Should open File Explorer
   - `Space g g` → Should open Source Control
   - `Space b b` → Should list all editors

### 3. Test Basic Vim Bindings

- `jk` in Insert mode → Should escape to Normal mode
- `Ctrl+h/j/k/l` → Should navigate between splits
- `Ctrl+z` → Should do nothing (disabled)

### 4. Test Sidebar Navigation

1. Open Explorer (`Cmd+Shift+E`)
2. Press `Space g g` → Should switch to Git view
3. Press `Space e` → Should switch back to Explorer
4. Press `Ctrl+l` → Should focus editor

## Troubleshooting

### Leader Key Mappings Not Working

**Check 1: Is vscode-neovim installed?**

```
Extensions → Search "Neo Vim" → Should see "Neo Vim" by asvetliakov
```

**Check 2: Is Neovim path correct?**

```bash
which nvim
# Output should match: /opt/homebrew/bin/nvim
```

If different, update `settings.json`:

```json
"vscode-neovim.neovimExecutablePaths.darwin": "/your/nvim/path"
```

**Check 3: Is Neovim loading?**

1. Open Output panel: `Cmd+Shift+U`
2. Select "Neovim" from dropdown
3. Look for messages like:
   ```
   Neovim initialized
   Loading init.lua
   ```

**Check 4: Reload VSCode**

```
Cmd+Shift+P → "Developer: Reload Window"
```

**Check 5: Test in Neovim directly**

Open a file in terminal Neovim and verify your keymaps work there:

```bash
nvim test.txt
# In Normal mode, try: Space f f
# This should trigger something (even if it doesn't work perfectly in terminal)
```

### jk Escape Not Working

**Problem**: Typing `jk` doesn't escape to Normal mode

**Solutions**:

1. **Type faster**: The keys must be pressed in quick succession
2. **Check settings**: Verify `compositeKeys` setting exists
3. **Try alternatives**: Use `Esc` or `Ctrl+[` instead

### Window Navigation Conflicts

**Problem**: `Ctrl+h/j/k/l` doesn't work or conflicts with other bindings

**Solutions**:

1. **Open keybindings**: `Cmd+K Cmd+S`
2. **Search conflicts**: Type `ctrl+h` and look for conflicts
3. **Remove conflicts**: Click the X next to conflicting keybindings
4. **Check "when" clauses**: Ensure they include `vim.active`

### Sidebar Mappings Not Working

**Problem**: `Space e`, `Space g g` don't work in sidebar

**Solutions**:

1. **Ensure focus is on sidebar**: Click in the sidebar first
2. **Check keybindings.json**: Verify mappings exist with `"when": "sideBarFocus"`
3. **Reload keybindings**: Save `keybindings.json` to reload

### Performance Issues

**Problem**: VSCode feels slow or laggy

**Solutions**:

1. **Check Neovim version**: Update to latest

   ```bash
   brew upgrade neovim
   ```

2. **Disable unnecessary plugins**: In your `init.lua`, disable plugins that don't work in VSCode

3. **Check Output panel**: Look for errors in Neovim output

4. **Reduce startup time**: Lazy-load plugins when possible

## Adding New Keybindings

### Add Leader Key Mapping

Edit `~/.config/nvim/lua/config/keymaps.lua`:

```lua
if vim.g.vscode then
  local vscode = require('vscode')

  -- Add your new mapping
  map('n', '<leader>xy', function()
    vscode.action('your.command.id')
  end, { desc = 'Your description' })
end
```

**Finding VSCode command IDs:**

1. Press `Cmd+Shift+P`
2. Type command name
3. Right-click the command
4. Select "Copy Command ID"

### Add Native VSCode Keybinding

Edit `keybindings.json`:

```json
{
  "key": "your key combination",
  "command": "command.id",
  "when": "context expression"
}
```

**Common "when" clauses:**

- `vim.mode == 'Normal'` - Only in Normal mode
- `sideBarFocus` - Only when sidebar has focus
- `editorTextFocus` - Only when editor has focus
- `vim.active` - Only when Vim mode is active

## Updating Configuration

### Sync with Neovim Changes

When you update your Neovim configuration:

1. **Edit** `~/.config/nvim/lua/config/keymaps.lua`
2. **Save** the file
3. **Reload VSCode** (`Cmd+Shift+P` → "Developer: Reload Window")
4. **Test** the new mappings

Changes to your Neovim config automatically apply to VSCode!

### Update Native Keybindings

When you update `keybindings.json`:

1. **Edit** the file
2. **Save** the file
3. Changes apply **immediately** (no reload needed)

## Debugging Tips

### Enable Neovim Logging

Add to your `settings.json`:

```json
"vscode-neovim.logLevel": "debug",
"vscode-neovim.logPath": "/tmp/vscode-neovim.log"
```

View logs:

```bash
tail -f /tmp/vscode-neovim.log
```

### Test Specific Commands

In VSCode:

1. Press `Cmd+Shift+P`
2. Type the command name manually
3. If it works manually but not with keybinding, it's a keybinding issue
4. If it doesn't work manually, it's a command/extension issue

### Check Vim Mode

In editor, check the status bar:

- Should show current mode (NORMAL, INSERT, VISUAL)
- If it doesn't show, vscode-neovim might not be active

## Common Issues Reference

| Issue                   | Symptom                  | Solution                                         |
| ----------------------- | ------------------------ | ------------------------------------------------ |
| No leader keys          | `Space f f` does nothing | Check vscode-neovim installation and Neovim path |
| jk doesn't work         | Stuck in Insert mode     | Type faster or use Esc                           |
| Slow typing             | Lag when typing          | Update Neovim, disable heavy plugins             |
| Ctrl+h/j/k/l conflict   | Navigation doesn't work  | Remove conflicting keybindings                   |
| Sidebar keys don't work | `Space e` does nothing   | Ensure focus is on sidebar                       |
| Changes not applying    | New keymaps don't work   | Reload VSCode window                             |

## Additional Resources

- [vscode-neovim GitHub](https://github.com/vscode-neovim/vscode-neovim)
- [VSCode Keybindings Docs](https://code.visualstudio.com/docs/getstarted/keybindings)
- [Neovim Documentation](https://neovim.io/doc/)

## Summary

Your setup provides:

- ✅ **Unified keybindings** between Neovim and VSCode
- ✅ **Full Vim capabilities** through actual Neovim integration
- ✅ **Native VSCode features** through complementary keybindings
- ✅ **Consistent experience** across both editors

All leader key mappings are defined once in your Neovim config and automatically work in VSCode!

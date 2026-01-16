# Leader Key Reference

This document provides a quick reference for understanding and using the leader key in your VSCode setup.

## What is a Leader Key?

The **leader key** is a prefix key that you press before other keys to trigger commands. Think of it as opening a "menu" of actions.

In your configuration:

- **Leader Key**: `Space` (matches LazyVim default)
- **Usage**: Press `Space` followed by other keys
- **Example**: `Space f f` opens the file finder

## Why Use a Leader Key?

✅ **Organized keybindings** - Groups related commands together
✅ **More combinations** - Expands available keybindings without conflicts
✅ **Muscle memory** - Consistent with Vim/Neovim conventions
✅ **Discoverable** - Logical groupings make commands easier to remember

## Leader Key Categories

Your keybindings are organized into logical categories:

| Prefix | Category              | Examples                                  |
| ------ | --------------------- | ----------------------------------------- |
| `f`    | **File** operations   | `ff` find files, `fr` recent files        |
| `s`    | **Search** operations | `sg` grep search, `sr` search & replace   |
| `b`    | **Buffer** operations | `bb` list buffers, `bd` delete buffer     |
| `c`    | **Code** actions      | `ca` code actions, `cr` rename            |
| `x`    | **Diagnostics**       | `xx` problems panel, `xd` next diagnostic |
| `g`    | **Git** operations    | `gg` status, `gc` commit, `gp` push       |
| `w`    | **Window** management | `wv` split vertical, `wh` navigate left   |
| `u`    | **UI** toggles        | `uw` word wrap, `uz` zen mode             |
| `t`    | **Terminal**          | `tt` toggle terminal, `tn` new terminal   |
| `h`    | **Help**              | `hk` keybindings, `hh` help               |
| `q`    | **Quit**              | `qq` close window, `qa` quit all          |

## Quick Reference

### Most Common Commands

| Keys                   | Action          | Description                  |
| ---------------------- | --------------- | ---------------------------- |
| `Space f f`            | Find files      | Quick open file picker       |
| `Space Space`          | Command palette | Search all commands          |
| `Space e`              | Toggle sidebar  | Show/hide entire sidebar     |
| `Space g g`            | Git status      | Open source control          |
| `Space b b`            | List buffers    | Show all open editors        |
| `Space c a`            | Code actions    | Quick fixes and refactoring  |
| `Space /` or `Space ?` | Search          | Find in current file/files   |
| `Space ,`              | Switch buffers  | Quick switch between editors |
| `Space .`              | Find files      | Alternative to `Space f f`   |

### File Operations

| Keys        | Action               |
| ----------- | -------------------- |
| `Space f f` | Find files           |
| `Space f r` | Recent files         |
| `Space f n` | New file             |
| `Space f g` | Find in files (grep) |
| `Space f w` | Save file            |

### Buffer Management

| Keys        | Action              |
| ----------- | ------------------- |
| `Space b b` | List all buffers    |
| `Space b d` | Delete/close buffer |
| `Space b n` | Next buffer         |
| `Space b p` | Previous buffer     |
| `Space b o` | Close other buffers |

### Code Operations

| Keys          | Action                   |
| ------------- | ------------------------ |
| `Space c a`   | Code actions (quick fix) |
| `Space c r`   | Rename symbol            |
| `Space c f`   | Format document          |
| `Space c d`   | Go to definition         |
| `Space c i`   | Organize imports         |
| `Space c c c` | Focus Cline view         |

### Window/Split Management

| Keys                       | Action                  |
| -------------------------- | ----------------------- |
| `Space w v` or `Space w\|` | Split vertical          |
| `Space w s` or `Space w -` | Split horizontal        |
| `Space w h/j/k/l`          | Navigate between splits |
| `Space w q`                | Close current split     |
| `Space w o`                | Close other splits      |

### Git Operations

| Keys        | Action                      |
| ----------- | --------------------------- |
| `Space g g` | Git status (source control) |
| `Space g b` | Git branches                |
| `Space g c` | Git commit                  |
| `Space g p` | Git push                    |
| `Space g l` | Git log                     |
| `Space g d` | Git diff                    |

## How Leader Keys Work

### In the Editor (Neovim Integration)

Leader keys are defined in `~/.config/nvim/lua/config/keymaps.lua`:

```lua
if vim.g.vscode then
  local vscode = require('vscode')

  -- Space is the leader key (set elsewhere)
  -- This maps Space + f + f to VSCode's quick open
  map('n', '<leader>ff', function()
    vscode.action('workbench.action.quickOpen')
  end, { desc = 'Find files' })
end
```

When you press `Space f f`:

1. `Space` activates leader mode
2. `f` narrows to file operations
3. Second `f` triggers "find files"

### In Sidebars (Native Keybindings)

Some leader keys work in sidebars via `keybindings.json`:

```json
{
  "key": "space e",
  "command": "workbench.view.explorer",
  "when": "sideBarFocus && !inputFocus"
}
```

This allows `Space e` to work even when focused on the sidebar.

## Leader Key vs Direct Keys

### Leader Keys (Space + ...)

- **Purpose**: Complex, less frequent operations
- **Example**: `Space c r` - Rename symbol
- **Benefit**: Doesn't conflict with normal typing

### Direct Keys (Ctrl/Cmd + ...)

- **Purpose**: Frequent, immediate operations
- **Example**: `Ctrl+s` - Save
- **Benefit**: Faster for common actions

### Your Configuration Uses Both

- **Leader keys**: Most operations (file, code, git, etc.)
- **Direct keys**: Window navigation (`Ctrl+h/j/k/l`), escape (`jk`)

## Consistency Across Editors

Your leader key configuration maintains consistency:

| Editor     | Leader Key | Configuration                           |
| ---------- | ---------- | --------------------------------------- |
| **Neovim** | `Space`    | `~/.config/nvim/lua/config/keymaps.lua` |
| **VSCode** | `Space`    | Same file + `keybindings.json`          |

Changes to your Neovim keymaps automatically apply to VSCode!

## Tips for Using Leader Keys

### 1. Think in Categories

- Need to find something? Try `Space f` or `Space s`
- Working with code? Try `Space c`
- Git operations? Try `Space g`

### 2. Common Patterns

- First letter often relates to action: `f`ind, `s`earch, `g`it
- Double letters often mean "show all": `ff` all files, `bb` all buffers

### 3. Muscle Memory

- Use the same keys across both Neovim and VSCode
- The more you use them, the more natural they become

### 4. Discoverability

- In VSCode, start typing `Space` and wait to see suggestions
- Check the keybindings panel: `Cmd+K Cmd+S`
- Reference this document or README.md for complete lists

## Customizing Leader Keys

### Add New Leader Key Mapping

Edit `~/.config/nvim/lua/config/keymaps.lua`:

```lua
if vim.g.vscode then
  local vscode = require('vscode')

  -- Add your custom mapping
  map('n', '<leader>ma', function()
    vscode.action('editor.action.selectAll')
  end, { desc = 'Select all - my custom mapping' })
end
```

Now `Space m a` will select all text!

### Change Leader Key

If you want to use a different leader key (e.g., `,` instead of `Space`):

Edit `~/.config/nvim/lua/config/options.lua` or `init.lua`:

```lua
vim.g.mapleader = ","  -- Change from Space to comma
```

⚠️ **Note**: This would require updating all leader key mappings!

## Comparison: VSCodeVim vs vscode-neovim

You're using **vscode-neovim**, which:

✅ Loads your actual Neovim config
✅ Leader keys defined once in Neovim config
✅ Automatically syncs with Neovim changes
✅ Uses real Neovim engine

**Alternative (VSCodeVim):**

- Separate Vim emulation
- Leader keys defined in `keybindings.json`
- Independent from your Neovim config
- Lighter weight but less feature-complete

## Summary

- ✅ **Leader key**: `Space` (matches LazyVim)
- ✅ **Configuration**: `~/.config/nvim/lua/config/keymaps.lua`
- ✅ **Categories**: File, Search, Buffer, Code, Git, Window, etc.
- ✅ **Consistency**: Same keybindings in Neovim and VSCode

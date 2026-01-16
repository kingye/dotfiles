# VSCode with Neovim Integration

This configuration provides a seamless Neovim experience in VSCode using the vscode-neovim extension, maintaining consistency with your LazyVim setup.

## Prerequisites

1. **VSCode Neovim Extension**

   ```bash
   code --install-extension asvetliakov.vscode-neovim
   ```

2. **Neovim** (required by the extension)

   ```bash
   brew install neovim
   ```

3. **Recommended Extensions**
   - ESLint: `dbaeumer.vscode-eslint`
   - Prettier: `esbenp.prettier-vscode`
   - GitHub Copilot: `github.copilot` (optional)

## Configuration Architecture

This setup uses a **dual-configuration approach**:

1. **Neovim Config** (`~/.config/nvim/lua/config/keymaps.lua`)

   - Provides leader key mappings via vscode-neovim extension
   - Works in the editor when in Vim modes (Normal, Insert, Visual)
   - Automatically syncs with your Neovim configuration

2. **VSCode Keybindings** (`keybindings.json`)
   - Provides native VSCode keybindings for enhanced Vim behavior
   - Handles sidebar navigation and window management
   - Works in non-Vim contexts (sidebar, panels, etc.)

This dual approach ensures keybindings work everywhere in VSCode, not just in the editor.

## Installation

1. **Copy Keybindings**

   ```bash
   # macOS/Linux
   cp vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
   ```

2. **Merge Settings**

   ```bash
   # Backup your current settings first!
   cp ~/Library/Application\ Support/Code/User/settings.json ~/Library/Application\ Support/Code/User/settings.json.backup

   # Then manually merge or replace
   cp vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
   ```

3. **Verify Neovim Path**

   Check that the Neovim path in `settings.json` matches your installation:

   ```json
   "vscode-neovim.neovimExecutablePaths.darwin": "/opt/homebrew/bin/nvim"
   ```

   Find your Neovim path:

   ```bash
   which nvim
   ```

4. **Reload VSCode**

   Press `Cmd+Shift+P` → "Developer: Reload Window"

## Keybindings Reference

### Basic Vim Mappings

| Key            | Mode   | Action                      | Source           |
| -------------- | ------ | --------------------------- | ---------------- |
| `jk`           | Insert | Escape to Normal mode       | Neovim config    |
| `Ctrl+z`       | All    | Disabled (no suspend)       | Both configs     |
| `Ctrl+h/j/k/l` | Normal | Navigate between splits     | Both configs     |
| `n` / `N`      | Normal | Search next/prev and center | keybindings.json |
| `<` / `>`      | Visual | Indent and reselect         | keybindings.json |
| `Shift+j/k`    | Visual | Move lines up/down          | keybindings.json |

### Leader Key Mappings (Space)

All leader key mappings are defined in your Neovim configuration and work automatically in VSCode through the vscode-neovim extension.

#### File Operations (`<Space>f`)

| Key         | Action               | VSCode Command    |
| ----------- | -------------------- | ----------------- |
| `<Space>ff` | Find files           | Quick Open        |
| `<Space>fr` | Recent files         | Open Recent       |
| `<Space>fn` | New file             | New Untitled File |
| `<Space>fg` | Find in files (grep) | Find in Files     |
| `<Space>fw` | Save file            | Save              |

#### Search Operations (`<Space>s`)

| Key         | Action              | VSCode Command   |
| ----------- | ------------------- | ---------------- |
| `<Space>sf` | Search files        | Quick Open       |
| `<Space>sg` | Search with grep    | Find in Files    |
| `<Space>sr` | Search and replace  | Replace in Files |
| `<Space>ss` | Search symbols      | Go to Symbol     |
| `<Space>sw` | Search word in file | Find             |

#### Buffer/Tab Operations (`<Space>b`)

| Key         | Action              | VSCode Command      |
| ----------- | ------------------- | ------------------- |
| `<Space>bb` | List all buffers    | Show All Editors    |
| `<Space>bd` | Delete/close buffer | Close Active Editor |
| `<Space>bn` | Next buffer         | Next Editor         |
| `<Space>bp` | Previous buffer     | Previous Editor     |
| `<Space>bo` | Close other buffers | Close Other Editors |

#### Code Actions (`<Space>c`)

| Key          | Action           | VSCode Command    |
| ------------ | ---------------- | ----------------- |
| `<Space>ca`  | Code actions     | Quick Fix         |
| `<Space>cr`  | Rename symbol    | Rename            |
| `<Space>cf`  | Format document  | Format Document   |
| `<Space>cd`  | Go to definition | Reveal Definition |
| `<Space>ci`  | Organize imports | Organize Imports  |
| `<Space>co`  | Source action    | Source Action     |
| `<Space>ccc` | Focus Cline      | Focus Cline View  |

#### Diagnostics/Problems (`<Space>x`)

| Key         | Action              | VSCode Command          |
| ----------- | ------------------- | ----------------------- |
| `<Space>xx` | Show problems panel | View Problems           |
| `<Space>xd` | Next diagnostic     | Next Problem Marker     |
| `<Space>xp` | Previous diagnostic | Previous Problem Marker |

#### Git Operations (`<Space>g`)

| Key         | Action       | VSCode Command      |
| ----------- | ------------ | ------------------- |
| `<Space>gg` | Git status   | Open Source Control |
| `<Space>gb` | Git branches | Checkout Branch     |
| `<Space>gc` | Git commit   | Commit              |
| `<Space>gp` | Git push     | Push                |
| `<Space>gl` | Git log      | View History        |
| `<Space>gd` | Git diff     | Open Change         |

#### Window/Split Management (`<Space>w`)

| Key                         | Action              | VSCode Command      |
| --------------------------- | ------------------- | ------------------- |
| `<Space>w\|` or `<Space>wv` | Split vertical      | Split Editor Right  |
| `<Space>w-` or `<Space>ws`  | Split horizontal    | Split Editor Down   |
| `<Space>ww`                 | Focus next window   | Focus Next Group    |
| `<Space>wq`                 | Close window        | Close Active Editor |
| `<Space>wo`                 | Close other windows | Join All Groups     |
| `<Space>wh`                 | Navigate left       | Navigate Left       |
| `<Space>wj`                 | Navigate down       | Navigate Down       |
| `<Space>wk`                 | Navigate up         | Navigate Up         |
| `<Space>wl`                 | Navigate right      | Navigate Right      |

#### UI Toggles (`<Space>u`)

| Key         | Action              | VSCode Command           |
| ----------- | ------------------- | ------------------------ |
| `<Space>uw` | Toggle word wrap    | Toggle Word Wrap         |
| `<Space>ul` | Toggle whitespace   | Toggle Render Whitespace |
| `<Space>un` | Toggle line numbers | Toggle Line Numbers      |
| `<Space>uz` | Toggle zen mode     | Toggle Zen Mode          |

#### Explorer & Sidebar

| Key        | Action         | VSCode Command            |
| ---------- | -------------- | ------------------------- |
| `<Space>e` | Toggle sidebar | Toggle Sidebar Visibility |
| `<Space>o` | Toggle sidebar | Toggle Sidebar Visibility |

#### Terminal (`<Space>t`)

| Key         | Action          | VSCode Command  |
| ----------- | --------------- | --------------- |
| `<Space>tt` | Toggle terminal | Toggle Terminal |
| `<Space>tn` | New terminal    | New Terminal    |

#### Quick Actions

| Key              | Action          | VSCode Command   |
| ---------------- | --------------- | ---------------- |
| `<Space><Space>` | Command palette | Show Commands    |
| `<Space>?`       | Find in files   | Find in Files    |
| `<Space>,`       | Switch buffers  | Show All Editors |
| `<Space>.`       | Find files      | Quick Open       |

#### Help & Quit

| Key         | Action      | VSCode Command          |
| ----------- | ----------- | ----------------------- |
| `<Space>hk` | Keybindings | Open Global Keybindings |
| `<Space>hh` | Help        | Show Commands           |
| `<Space>qq` | Quit window | Close Window            |
| `<Space>qa` | Quit all    | Quit                    |

### Sidebar-Specific Mappings

These keybindings work when focused on sidebars (Explorer, Git, Search, etc.) and are defined in `keybindings.json`:

| Key         | Action               | Notes                       |
| ----------- | -------------------- | --------------------------- |
| `<Space>e`  | Switch to Explorer   | From any sidebar            |
| `<Space>gg` | Switch to Git        | From any sidebar            |
| `<Space>sg` | Switch to Search     | From any sidebar            |
| `Ctrl+l`    | Focus editor         | Leave sidebar, focus editor |
| `Enter`     | Focus search results | In search view              |

## Configuration Details

### Editor Settings

LazyVim-inspired settings configured in `settings.json`:

- **Relative line numbers** - Like LazyVim
- **Scroll offset** - Keep 8 lines visible above/below cursor
- **No minimap** - Clean interface
- **Smooth scrolling** - Animated cursor movement
- **Rulers at 80 and 120** - Code width guidelines
- **Auto-save on focus change** - Convenience feature

### Language Support

Pre-configured formatters:

- **TypeScript/JavaScript** - Prettier + ESLint
- **React/Angular** - JSX/TSX support
- **Rust** - rust-analyzer
- **Markdown** - Word wrap enabled
- **JSON/TOML** - Auto-formatting

### Auto-formatting on Save

- Organize imports
- Fix ESLint issues
- Apply Prettier formatting
- Trim trailing whitespace

## How It Works

1. **vscode-neovim loads your Neovim config** from `~/.config/nvim/init.lua`
2. **The `vim.g.vscode` flag is set** when running in VSCode
3. **VSCode-specific keymaps activate** (the `if vim.g.vscode then` block in `keymaps.lua`)
4. **Leader key mappings work** using the `vscode.action()` API
5. **Native keybindings complement** Vim mappings for full VSCode integration

## Testing Your Setup

1. **Reload VSCode**: `Cmd+Shift+P` → "Developer: Reload Window"
2. **Enter Normal Mode**: Press `Esc` or `jk`
3. **Test Leader Key Mappings**:
   - `Space f f` → Find files
   - `Space b b` → List buffers
   - `Space e` → File explorer
   - `Space g g` → Git status
   - `Space c a` → Code actions

## Troubleshooting

### Leader key mappings not working?

1. **Verify vscode-neovim is installed and enabled**

   - Check Extensions: Look for "Neo Vim" by asvetliakov

2. **Check Neovim path**:

   ```bash
   which nvim
   # Should match the path in settings.json
   ```

3. **Reload VSCode**:

   - `Cmd+Shift+P` → "Developer: Reload Window"

4. **Check Neovim is loading**:

   - Open Output panel: `Cmd+Shift+U`
   - Select "Neovim" from dropdown
   - Look for initialization messages

5. **Verify you're in Normal mode**:
   - Press `Esc` to ensure you're in Normal mode
   - Status bar should indicate `-- NORMAL --`

### jk escape not working?

1. Ensure you're in Insert mode
2. Type `j` followed quickly by `k`
3. Check that vscode-neovim is active
4. Verify the composite key setting in `settings.json`

### Window navigation conflicts?

If `Ctrl+h/j/k/l` conflicts with other keybindings:

1. Open keyboard shortcuts: `Cmd+K Cmd+S`
2. Search for conflicting bindings
3. Remove or modify conflicting shortcuts

## Customization

### Adding New Leader Key Mappings

Edit `~/.config/nvim/lua/config/keymaps.lua` inside the `if vim.g.vscode then` block:

```lua
map('n', '<leader>xy', function() vscode.action('command.id') end, { desc = 'Description' })
```

To find VSCode command IDs:

1. Press `Cmd+Shift+P`
2. Type the command name
3. Click the gear icon next to it
4. The command ID will be shown

### Adding Native VSCode Keybindings

Edit `keybindings.json` for keybindings that should work outside the editor:

```json
{
  "key": "ctrl+shift+x",
  "command": "workbench.view.extensions",
  "when": "sideBarFocus"
}
```

## Differences from Pure Neovim

While this configuration closely mirrors LazyVim, some differences exist:

1. **Plugin ecosystem** - Some Neovim plugins don't work in VSCode
2. **Modal editing feel** - Slightly different from native Neovim
3. **LSP integration** - Uses VSCode's built-in LSP
4. **File explorer** - VSCode's native explorer instead of neo-tree
5. **Terminal** - VSCode's integrated terminal instead of toggleterm
6. **Git UI** - VSCode's native Git UI instead of lazygit

## Benefits of This Approach

✅ **Single source of truth** - Keymaps defined once in Neovim config
✅ **Automatic sync** - Changes to Neovim config reflect in VSCode
✅ **Consistent muscle memory** - Same keybindings across editors
✅ **Full VSCode integration** - Native keybindings complement Vim mappings
✅ **Best of both worlds** - Neovim editing with VSCode features

## Resources

- [vscode-neovim Documentation](https://github.com/vscode-neovim/vscode-neovim)
- [LazyVim Documentation](https://www.lazyvim.org/)
- [VSCode Keybindings Guide](https://code.visualstudio.com/docs/getstarted/keybindings)

---

**Note**: This configuration stays in sync with your LazyVim setup. Changes to `nvim/lua/config/keymaps.lua` automatically apply to VSCode.

# Vim

## setup in vscode

### in vscode user settings add:

```
 "vim.leader": "<Space>",
  "vim.insertModeKeyBindings": [{ "before": ["k", "j"], "after": ["<Esc>"] }],
  "vim.normalModeKeyBindingsNonRecursive": [
        // NAVIGATION
    // switch b/w buffers
    { "before": ["<S-h>"], "commands": [":bprevious"] },
    { "before": ["<S-l>"], "commands": [":bnext"] },
    // splits
    { "before": ["leader", "v"], "commands": [":vsplit"] },
    { "before": ["leader", "s"], "commands": [":split"] },
    {
      "before": ["<leader>", "g", "d"],
      "commands": ["editor.action.revealDefinition"]
    },
    {
      "before": ["<leader>", "g", "D"],
      "commands": ["editor.action.revealDeclaration"]
    },
    {
      "before": ["leader", "s"],
      "commands": ["workbench.action.findInFiles"]
    },
    // panes
    {
      "before": ["leader", "h"],
      "commands": ["workbench.action.focusLeftGroup"]
    },
    {
      "before": ["leader", "j"],
      "commands": ["workbench.action.focusBelowGroup"]
    },
    {
      "before": ["leader", "k"],
      "commands": ["workbench.action.focusAboveGroup"]
    },
    {
      "before": ["leader", "l"],
      "commands": ["workbench.action.focusRightGroup"]
    },
    {
      "before": ["leader", "e", "l"],
      "commands": ["workbench.action.nextEditor"]
    },
    {
      "before": ["leader", "e", "h"],
      "commands": ["workbench.action.previousEditor"]
    },
    // NICE TO HAVE
    {
      "before": ["<leader>", "c", "a"],
      "commands": ["editor.action.quickFix"]
    },
    { "before": ["leader", "f"], "commands": ["workbench.action.quickOpen"] },
    {
      "before": ["leader", "g", "f"],
      "commands": ["editor.action.formatDocument"]
    },
    // debugging
    {
      "before": ["<leader>", "d", "a"],
      "commands": ["workbench.action.debug.selectandstart"]
    },
    {
      "before": ["<leader>", "d", "t"],
      "commands": ["editor.debug.action.toggleBreakpoint"],
      "when": "debuggersAvailable"
    },
    {
      "before": ["<leader>", "d", "o"],
      "commands": ["workbench.action.debug.stepOver"],
      "when": "debugState == 'stopped'"
    },
    {
      "before": ["<leader>", "d", "O"],
      "commands": ["workbench.action.debug.stepOut"],
      "when": "debugState == 'stopped'"
    },
    {
      "before": ["<leader>", "d", "i"],
      "commands": ["workbench.action.debug.stepInto"],
      "when": "debugState != 'inactive'"
    },
    {
      "before": ["<leader>", "d", "s"],
      "commands": ["workbench.action.debug.stop"],
      "when": "debugState != 'inactive'"
    },
    {
      "before": ["<leader>", "d", "c"],
      "commands": ["workbench.action.debug.continue"],
      "when": "debugState == 'stopped'"
    },
    {
      "before": ["<leader>", "t", "d"],
      "commands": ["testing.debugAtCursor"]
    }
  ],
```

### in keybindings.json

```
{
    "key": "ctrl+`",
    "command": "-workbench.action.selectTheme"
  },
  {
    "key": "ctrl+r",
    "command": "-workbench.action.tasks.reRunTask"
  },
  // NAVIGATION
  {
    "key": "ctrl+shift+a",
    "command": "workbench.action.terminal.focusNext",
    "when": "terminalFocus"
  },
  {
    "key": "ctrl+shift+b",
    "command": "workbench.action.terminal.focusPrevious",
    "when": "terminalFocus"
  },
  {
    "key": "ctrl+shift+e",
    "command": "workbench.action.focusActiveEditorGroup"
  },
  {
    "key": "ctrl+shift+t",
    "command": "workbench.action.terminal.toggleTerminal"
  },
  {
    "key": "ctrl+shift+n",
    "command": "workbench.action.terminal.new",
    "when": "terminalFocus"
  },
  {
    "key": "ctrl+shift+w",
    "command": "workbench.action.terminal.kill",
    "when": "terminalFocus"
  },
  // FILE TREE
  {
    "command": "workbench.files.action.focusFilesExplorer",
    "key": "ctrl+shift+s",
    "when": "!sidebarFocus"
  },
  {
    "command": "workbench.action.toggleSidebarVisibility",
    "key": "ctrl+shift+s",
    "when": "!editorTextFocus"
  },
  {
    "key": "n",
    "command": "explorer.newFile",
    "when": "filesExplorerFocus && !inputFocus"
  },
  {
    "command": "renameFile",
    "key": "r",
    "when": "filesExplorerFocus && !inputFocus"
  },
  {
    "key": "shift+n",
    "command": "explorer.newFolder",
    "when": "explorerViewletFocus"
  },
  {
    "key": "shift+n",
    "command": "workbench.action.newWindow",
    "when": "!explorerViewletFocus"
  },
  {
    "command": "deleteFile",
    "key": "d",
    "when": "filesExplorerFocus && !inputFocus"
  },

  // EXTRA
  {
    "key": "ctrl+shift+5",
    "command": "editor.emmet.action.matchTag"
  },
  {
    "key": "ctrl+z",
    "command": "workbench.action.toggleZenMode"
  }
```

## Macro

- record

```
q<register>
...
q

```

- replay

```

@<register>

```

## Insert text before every line

- C-V to enter into virtual block mode
- Shit-I to enter into insert mode
- type the text
- ESC

## Surround
1. Surround using visual mode
  - `v` entern into visual mode
  - select the text
  - `S(` to surround with `()`
2. Surround with word
  - `ysiw(`: in word without space
  - `ysw(`: with space
3. Change surround
  - `cs[(`
## replace with yank

- v
- selection
- p

## Switch between tabs

Next tab: gt

Prior tab: gT

Numbered tab: nnngt

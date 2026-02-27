-- VSCode-specific keymaps
-- This file contains all keybindings for VSCode Neovim integration

if not vim.g.vscode then
  return
end

local vscode = require('vscode')
local map = vim.keymap.set

-- File Operations
map('n', '<leader>ff', function() vscode.action('workbench.action.quickOpen') end, { desc = 'Find files' })
map('n', '<leader>fr', function() vscode.action('workbench.action.openRecent') end, { desc = 'Recent files' })
map('n', '<leader>fn', function() vscode.action('workbench.action.files.newUntitledFile') end, { desc = 'New file' })
map('n', '<leader>fg', function() vscode.action('workbench.action.findInFiles') end, { desc = 'Find in files' })
map('n', '<leader>fw', function() vscode.action('workbench.action.files.save') end, { desc = 'Save file' })

-- Search Operations
map('n', '<leader>sf', function() vscode.action('workbench.action.quickOpen') end, { desc = 'Search files' })
map('n', '<leader>sg', function() vscode.action('workbench.action.findInFiles') end, { desc = 'Search grep' })
map('n', '<leader>sr', function() vscode.action('workbench.action.replaceInFiles') end, { desc = 'Search replace' })
map('n', '<leader>ss', function() vscode.action('workbench.action.gotoSymbol') end, { desc = 'Search symbols' })
map('n', '<leader>sw', function() vscode.action('actions.find') end, { desc = 'Search word' })

-- Buffer/Tab Operations
map('n', '<leader>bb', function() vscode.action('workbench.action.showAllEditors') end, { desc = 'List buffers' })
map('n', '<leader>bd', function() vscode.action('workbench.action.closeActiveEditor') end, { desc = 'Delete buffer' })
map('n', '<leader>bn', function() vscode.action('workbench.action.nextEditor') end, { desc = 'Next buffer' })
map('n', '<leader>bp', function() vscode.action('workbench.action.previousEditor') end, { desc = 'Previous buffer' })
map('n', '<leader>bo', function() vscode.action('workbench.action.closeOtherEditors') end,
  { desc = 'Close other buffers' })

-- Code Actions
map('n', '<leader>ca', function() vscode.action('editor.action.quickFix') end, { desc = 'Code actions' })
map('n', '<leader>cr', function() vscode.action('editor.action.rename') end, { desc = 'Rename' })
map('n', '<leader>cf', function() vscode.action('editor.action.formatDocument') end, { desc = 'Format document' })
map('n', '<leader>cd', function() vscode.action('editor.action.revealDefinition') end, { desc = 'Go to definition' })
map('n', '<leader>ci', function() vscode.action('editor.action.organizeImports') end, { desc = 'Organize imports' })
map('n', '<leader>co', function() vscode.action('editor.action.sourceAction') end, { desc = 'Source action' })

-- Diagnostics
map('n', '<leader>xx', function() vscode.action('workbench.actions.view.problems') end, { desc = 'Show problems' })
map('n', '<leader>xd', function() vscode.action('editor.action.marker.next') end, { desc = 'Next diagnostic' })
map('n', '<leader>xp', function() vscode.action('editor.action.marker.prev') end, { desc = 'Previous diagnostic' })

-- Git Operations
map('n', '<leader>gg', function() vscode.action('workbench.view.scm') end, { desc = 'Git status' })
map('n', '<leader>gb', function() vscode.action('git.checkout') end, { desc = 'Git branches' })
map('n', '<leader>gc', function() vscode.action('git.commit') end, { desc = 'Git commit' })
map('n', '<leader>gp', function() vscode.action('git.push') end, { desc = 'Git push' })
map('n', '<leader>gl', function() vscode.action('git.viewHistory') end, { desc = 'Git log' })
map('n', '<leader>gd', function() vscode.action('git.openChange') end, { desc = 'Git diff' })

-- Explorer/Sidebar
-- Note: workbench.files.action.focusFilesExplorer ensures we open the Files view,
-- not other explorer views like Rust Dependencies. This works in conjunction with
-- keybindings.json which has a Rust-specific override for the same behavior.
map('n', '<leader>e', function() vscode.action('workbench.files.action.focusFilesExplorer') end,
  { desc = 'Open folder' })
map('n', '<leader>o', function() vscode.action('workbench.action.toggleSidebarVisibility') end,
  { desc = 'Toggle sidebar' })
map('n', '<leader>p', function() vscode.action('workbench.action.togglePanel') end, { desc = 'Toggle panel' })

-- Terminal
map('n', '<leader>ft', function() vscode.action('workbench.action.terminal.toggleTerminal') end,
  { desc = 'Toggle terminal' })
map('n', '<leader>tn', function() vscode.action('workbench.action.terminal.new') end, { desc = 'New terminal' })

-- Window/Split Management
-- Using <Bar> instead of | for better compatibility
map('n', '<leader><Bar>', function() vscode.action('workbench.action.splitEditorRight') end,
  { desc = 'Split vertical' })
map('n', '<leader>-', function() vscode.action('workbench.action.splitEditorDown') end, { desc = 'Split horizontal' })
map('n', '<leader>wv', function() vscode.action('workbench.action.splitEditorRight') end, { desc = 'Split vertical' })
map('n', '<leader>ws', function() vscode.action('workbench.action.splitEditorDown') end, { desc = 'Split horizontal' })
map('n', '<leader>ww', function() vscode.action('workbench.action.focusNextGroup') end, { desc = 'Focus next window' })
map('n', '<leader>wq', function() vscode.action('workbench.action.closeActiveEditor') end, { desc = 'Close window' })
map('n', '<leader>wo', function() vscode.action('workbench.action.joinAllGroups') end, { desc = 'Close other windows' })
map('n', '<leader>wh', function() vscode.action('workbench.action.navigateLeft') end, { desc = 'Navigate left' })
map('n', '<leader>wj', function() vscode.action('workbench.action.navigateDown') end, { desc = 'Navigate down' })
map('n', '<leader>wk', function() vscode.action('workbench.action.navigateUp') end, { desc = 'Navigate up' })
map('n', '<leader>wl', function() vscode.action('workbench.action.navigateRight') end, { desc = 'Navigate right' })

-- UI Toggles
map('n', '<leader>uw', function() vscode.action('editor.action.toggleWordWrap') end, { desc = 'Toggle word wrap' })
map('n', '<leader>ul', function() vscode.action('editor.action.toggleRenderWhitespace') end,
  { desc = 'Toggle whitespace' })
map('n', '<leader>un', function() vscode.action('workbench.action.toggleLineNumbers') end,
  { desc = 'Toggle line numbers' })
map('n', '<leader>uz', function() vscode.action('workbench.action.toggleZenMode') end, { desc = 'Toggle zen mode' })

-- Quick Actions
map('n', '<leader><leader>', function() vscode.action('workbench.action.showCommands') end,
  { desc = 'Command palette' })
-- Note: space / doesn't work well in VSCode neovim due to / being a native Vim search trigger
-- Using space ? as alternative for find in files (? is reverse search in vim, less commonly used)
map('n', '<leader>?', function() vscode.action('workbench.action.findInFiles') end, { desc = 'Find in files' })
map('n', '<leader>,', function() vscode.action('workbench.action.showAllEditors') end, { desc = 'Switch buffers' })
map('n', '<leader>.', function() vscode.action('workbench.action.quickOpen') end, { desc = 'Find files' })

-- Help
map('n', '<leader>hk', function() vscode.action('workbench.action.openGlobalKeybindings') end, { desc = 'Keybindings' })
map('n', '<leader>hh', function() vscode.action('workbench.action.showCommands') end, { desc = 'Help' })

-- Quit
map('n', '<leader>qq', function() vscode.action('workbench.action.closeWindow') end, { desc = 'Quit window' })
map('n', '<leader>qa', function() vscode.action('workbench.action.quit') end, { desc = 'Quit all' })

-- Window navigation with Ctrl+hjkl
map('n', '<C-h>', function() vscode.action('workbench.action.navigateLeft') end, { desc = 'Navigate left' })
map('n', '<C-j>', function() vscode.action('workbench.action.navigateDown') end, { desc = 'Navigate down' })
map('n', '<C-k>', function() vscode.action('workbench.action.navigateUp') end, { desc = 'Navigate up' })
map('n', '<C-l>', function() vscode.action('workbench.action.navigateRight') end, { desc = 'Navigate right' })

-- Buffer navigation with [b and ]b
map('n', '[b', function() vscode.action('workbench.action.previousEditor') end, { desc = 'Previous buffer' })
map('n', ']b', function() vscode.action('workbench.action.nextEditor') end, { desc = 'Next buffer' })

-- Start Cline
map('n', '<leader>ccc', function() vscode.action('claude-dev.SidebarProvider.focus') end, { desc = 'Start cline' })

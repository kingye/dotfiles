-- Smart pane navigation: Neovim splits OR WezTerm panes
-- This allows seamless navigation between Neovim windows and WezTerm panes

if vim.g.vscode then
  return
end

local wezterm = require('wezterm')
local map = vim.keymap.set

local function navigate_or_switch(direction)
  -- Map direction to vim window command
  local direction_keys = {
    Left = 'h',
    Right = 'l',
    Up = 'k',
    Down = 'j'
  }

  local key = direction_keys[direction]
  if not key then return end

  -- Get current window ID
  local current_win = vim.fn.win_getid()

  -- Try to move in Neovim
  vim.cmd('wincmd ' .. key)

  -- Check if we actually moved to a different window
  local new_win = vim.fn.win_getid()

  -- If we didn't move, we're at the edge - switch to WezTerm pane
  if current_win == new_win then
    wezterm.switch_pane.direction(direction)
  end
end

-- Pane navigation keymaps
map('n', '<C-h>', function() navigate_or_switch('Left') end, { desc = 'Navigate left (Neovim/WezTerm)' })
map('n', '<C-j>', function() navigate_or_switch('Down') end, { desc = 'Navigate down (Neovim/WezTerm)' })
map('n', '<C-k>', function() navigate_or_switch('Up') end, { desc = 'Navigate up (Neovim/WezTerm)' })
map('n', '<C-l>', function() navigate_or_switch('Right') end, { desc = 'Navigate right (Neovim/WezTerm)' })

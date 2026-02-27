local wezterm = require("wezterm")
local act = wezterm.action

-- Helper function to check if current process is nvim
local function is_vim(pane)
  local process_name = pane:get_foreground_process_name()
  return process_name and (process_name:find('nvim') or process_name:find('vim'))
end

-- Smart navigation: pass through to nvim if in nvim, otherwise switch panes
local function navigate(direction_key, direction_name)
  return wezterm.action_callback(function(window, pane)
    if is_vim(pane) then
      -- Send the key to Neovim
      window:perform_action(act.SendKey({ key = direction_key, mods = 'CTRL' }), pane)
    else
      -- Not in Neovim, switch WezTerm pane
      window:perform_action(act.ActivatePaneDirection(direction_name), pane)
    end
  end)
end

local config = {
  leader = { key = 's', mods = 'CTRL', timeout_milliseconds = 5000 },
  keys = {
    {
      key = '"',
      mods = 'LEADER',
      action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" }
    },
    {
      key = '%',
      mods = 'LEADER',
      action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" }
    },
    -- Smart Neovim + WezTerm navigation
    { key = 'h', mods = 'CTRL',     action = navigate('h', 'Left') },
    { key = 'j', mods = 'CTRL',     action = navigate('j', 'Down') },
    { key = 'k', mods = 'CTRL',     action = navigate('k', 'Up') },
    { key = 'l', mods = 'CTRL',     action = navigate('l', 'Right') },

    { key = 'k', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize({ 'Up', 10 }) },
    { key = 'j', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize({ 'Down', 10 }) },
    { key = 'h', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize({ 'Left', 10 }) },
    { key = 'l', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize({ 'Right', 10 }) },
    {
      key = "f",
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ScrollByPage(1)
    },
    {
      key = "b",
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ScrollByPage(-1)
    },
    {
      key = "u",
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ScrollByPage(-0.5)
    },
    {
      key = "d",
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ScrollByPage(0.5)
    },
    {
      key = 's',
      mods = 'LEADER',
      action = wezterm.action.ShowLauncher
    },
    {
      key = 'z',
      mods = 'LEADER',
      action = wezterm.action.TogglePaneZoomState
    },
    {
      key = 'y',
      mods = 'LEADER',
      action = 'ActivateCopyMode'
    },
    {
      key = 'c',
      mods = 'LEADER',
      action = wezterm.action { SpawnTab = "CurrentPaneDomain" }
    },
    {
      key = 'n',
      mods = 'LEADER',
      action = wezterm.action.ActivateTabRelative(1)
    },
    {
      key = 'p',
      mods = 'LEADER',
      action = wezterm.action.ActivateTabRelative(-1)
    },
    {
      key = ']',
      mods = 'LEADER',
      action = wezterm.action.ActivateTabRelative(1)
    },
    {
      key = '[',
      mods = 'LEADER',
      action = wezterm.action.ActivateTabRelative(-1)
    },
    {
      key = '{',
      mods = 'LEADER',
      action = wezterm.action.MoveTabRelative(-1)
    },
    {
      key = '}',
      mods = 'LEADER',
      action = wezterm.action.MoveTabRelative(1)
    },
    {
      key = '&',
      mods = 'LEADER',
      action = wezterm.action.CloseCurrentTab { confirm = false }
    },
    {
      key = 'x',
      mods = 'LEADER',
      action = wezterm.action.CloseCurrentPane { confirm = true }
    },
    {
      key = 'w',
      mods = 'LEADER',
      action = wezterm.action.SpawnWindow
    },
    -- Rotate panes
    {
      key = 'o',
      mods = 'LEADER',
      action = wezterm.action.RotatePanes 'Clockwise'
    },
    {
      key = 'O',
      mods = 'LEADER|SHIFT',
      action = wezterm.action.RotatePanes 'CounterClockwise'
    },

    -- key-tables --
    -- resizes fonts
    {
      key = 'f',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
        name = 'resize_font',
        one_shot = false,
        timeout_milliseconds = 1000,
      }),
    },
    -- resize panes
    {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
        name = 'resize_pane',
        one_shot = false,
        timeout_milliseconds = 1000,
      }),
    },
  },
  disable_default_key_bindings = true,

  key_tables = {
    resize_font =
    {
      { key = '+',      action = act.IncreaseFontSize },
      { key = '-',      action = act.DecreaseFontSize },
      { key = 'r',      action = act.ResetFontSize },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
    },
    resize_pane = {
      { key = 'k',      action = act.AdjustPaneSize({ 'Up', 10 }) },
      { key = 'j',      action = act.AdjustPaneSize({ 'Down', 10 }) },
      { key = 'h',      action = act.AdjustPaneSize({ 'Left', 10 }) },
      { key = 'l',      action = act.AdjustPaneSize({ 'Right', 10 }) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
    },
  }
}

return config

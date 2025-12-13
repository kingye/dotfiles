local wezterm = require("wezterm")
local sessions = wezterm.plugin.require("https://github.com/abidibo/wezterm-sessions")
local config = {
    leader = {key='s', mods='CTRL', timeout_milliseconds=5000},
    keys = {
      {
          key = '"',
          mods = 'LEADER',
          action = wezterm.action.SplitVertical {domain="CurrentPaneDomain"}
      },
      {
          key = '%',
          mods = 'LEADER',
          action = wezterm.action.SplitHorizontal {domain="CurrentPaneDomain"}
      },
      {
          key = 'h',
          mods = 'LEADER|CTRL',
          action = wezterm.action.ActivatePaneDirection 'Left'
      },
      {
        key = 'l',
        mods = 'LEADER|CTRL',
        action = wezterm.action.ActivatePaneDirection 'Right'
      },
      {
        key = 'k',
        mods = 'LEADER|CTRL',
        action = wezterm.action.ActivatePaneDirection 'Up'
      },
      { key = 'j',
        mods = 'LEADER|CTRL',
        action = wezterm.action.ActivatePaneDirection 'Down'
      },
      {
        key = 'h',
        mods = 'LEADER|SHIFT',
        action = wezterm.action.AdjustPaneSize {'Left', 5},
      },
      {
        key = 'l',
        mods = 'LEADER|SHIFT',
        action = wezterm.action.AdjustPaneSize {'Right', 5}
      },
      {
        key = 'j',
        mods = 'LEADER|SHIFT',
        action = wezterm.action.AdjustPaneSize {'Down', 5}
      },
      {
        key = 'k',
        mods = 'LEADER|SHIFT',
        action = wezterm.action.AdjustPaneSize {'Up', 5}
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

      -- wezterm-sessions plugin
      {
        key = 's',
        mods = 'LEADER|CTRL',
        action = wezterm.action {EmitEvent = 'save_session'}
      },
      {
        key = 'l',
        mods = 'LEADER|CTRL',
        action = wezterm.action {EmitEvent = 'load_session'}
      },
      {
          key = 'r',
          mods = 'LEADER|CTRL',
          action = wezterm.action({ EmitEvent = "restore_session" }),
      },
      -- {
      --     key = 'd',
      --     mods = 'LEADER|SHIFT',
      --     action = wezterm.action({ EmitEvent = "delete_session" }),
      -- },
      -- {
      --     key = 'e',
      --     mods = 'LEADER|SHIFT',
      --     action = wezterm.action({ EmitEvent = "edit_session" }),
      -- },
      -- Rename current workspace
      {
          key = '$',
          mods = 'LEADER|SHIFT',
          action = wezterm.action.PromptInputLine {
              description = 'Enter new workspace name',
              action = wezterm.action_callback(
                  function(window, pane, line)
                      if line then
                          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
                      end
                  end
              ),
          },
      },
      -- Prompt for a name to use for a new workspace and switch to it.
      {
          key = 'c',
          mods = 'LEADER|SHIFT',
          action = wezterm.action.PromptInputLine {
              description = wezterm.format {
                  { Attribute = { Intensity = 'Bold' } },
                  { Foreground = { AnsiColor = 'Fuchsia' } },
                  { Text = 'Enter name for new workspace' },
              },
              action = wezterm.action_callback(function(window, pane, line)
                  -- line will be `nil` if they hit escape without entering anything
                  -- An empty string if they just hit enter
                  -- Or the actual line of text they wrote
                  if line then
                      window:perform_action(
                          act.SwitchToWorkspace {
                              name = line,
                          },
                          pane
                      )
                  end
              end),
          },
      },
    },
    font_size = 13,
    font = wezterm.font("JetBrainsMonoNL Nerd Font", { weight = "Regular" }),
    color_scheme = "Catppuccin Mocha",
    line_height = 1.2,
    use_fancy_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true,
    window_decorations = "RESIZE",
    show_tab_index_in_tab_bar = false,
    window_background_opacity = 0.9,
    macos_window_background_blur = 70,

    text_background_opacity = 0.9,
    adjust_window_size_when_changing_font_size = false,
    window_padding = {
        left = 10,
        right = 10,
        top = 10,
        bottom = 10,
    },
}

return config

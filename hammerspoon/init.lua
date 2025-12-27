-- git clone https://github.com/mogenson/PaperWM.spoon ~/.hammerspoon/Spoons/PaperWM.spoon
PaperWM = hs.loadSpoon("PaperWM")
PaperWM:bindHotkeys({
  -- switch to a new focused window in tiled grid
  focus_left           = { { "alt" }, "h" },
  focus_right          = { { "alt" }, "l" },
  focus_up             = { { "alt" }, "k" },
  focus_down           = { { "alt" }, "j" },

  -- switch windows by cycling forward/backward
  -- (forward = down or right, backward = up or left)
  focus_prev           = { { "alt" }, "[" },
  focus_next           = { { "alt" }, "]" },

  -- move windows around in tiled grid
  swap_left            = { { "alt", "shift" }, "h" },
  swap_right           = { { "alt", "shift" }, "l" },
  swap_up              = { { "alt", "shift" }, "k" },
  swap_down            = { { "alt", "shift" }, "j" },

  -- position and resize focused window
  center_window        = { { "alt" }, "c" },
  full_width           = { { "alt" }, "z" },
  cycle_width          = { { "alt" }, "w" },
  reverse_cycle_width  = { { "alt", "shift" }, "w" },
  cycle_height         = { { "alt" }, "t" },
  reverse_cycle_height = { { "alt", "shift" }, "t" },

  -- increase/decrease width
  increase_width       = { { "alt" }, "=" },
  decrease_width       = { { "alt" }, "-" },

  -- move focused window into / out of a column
  slurp_in             = { { "alt" }, "i" },
  barf_out             = { { "alt" }, "o" },

  -- move the focused window into / out of the tiling layer
  toggle_floating      = { { "alt" }, "f" },

  -- focus the first / second / etc window in the current space
  focus_window_1       = { { "alt" }, "'" },

  -- switch to a new Mission Control space
  switch_space_l       = { { "alt" }, "," },
  switch_space_r       = { { "alt" }, "." },
  switch_space_1       = { { "alt" }, "1" },
  switch_space_2       = { { "alt" }, "2" },
  switch_space_3       = { { "alt" }, "3" },
  switch_space_4       = { { "alt" }, "4" },
  switch_space_5       = { { "alt" }, "5" },
  switch_space_6       = { { "alt" }, "6" },
  switch_space_7       = { { "alt" }, "7" },
  switch_space_8       = { { "alt" }, "8" },
  switch_space_9       = { { "alt" }, "9" },

  -- move focused window to a new space and tile
  move_window_1        = { { "alt", "shift" }, "1" },
  move_window_2        = { { "alt", "shift" }, "2" },
  move_window_3        = { { "alt", "shift" }, "3" },
  move_window_4        = { { "alt", "shift" }, "4" },
  move_window_5        = { { "alt", "shift" }, "5" },
  move_window_6        = { { "alt", "shift" }, "6" },
  move_window_7        = { { "alt", "shift" }, "7" },
  move_window_8        = { { "alt", "shift" }, "8" },
  move_window_9        = { { "alt", "shift" }, "9" }
})
PaperWM.window_gap    = { top = 8, bottom = 8, left = 8, right = 8 }
PaperWM.window_ratios = { 1 / 4, 1 / 3, 1 / 2, 2 / 3, 3 / 4 }
PaperWM:start()

FocusMode = hs.loadSpoon("FocusMode")
-- Optional: tweak settings before start
FocusMode.dimAlpha = 0.36
FocusMode.mouseDim = false
-- spoon.FocusMode.windowCornerRadius = 6
-- spoon.FocusMode.eventSettleDelay = 0.03 -- smoother with tilers

-- Optional: custom hotkeys
-- spoon.FocusMode:bindHotkeys({
--   start = { {"ctrl","alt","cmd"}, "I" },
--   stop  = { {"ctrl","alt","cmd"}, "O" },
-- })

-- Start (you can also use the hotkey)
FocusMode:start()

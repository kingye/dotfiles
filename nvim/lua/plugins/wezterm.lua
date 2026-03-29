return {
  "willothy/wezterm.nvim",
  cond = vim.fn.executable("wezterm") == 1,
  event = "VeryLazy",
  config = true
}

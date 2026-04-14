-- OSC52 plugin for clipboard over SSH
return {
  {
    'ojroques/nvim-osc52',
    lazy = true,
    -- Always load on Linux, optional on macOS
    cond = function()
      local is_mac = vim.fn.has('mac') == 1
      local is_linux = vim.fn.has('unix') == 1 and not is_mac
      -- Always load on Linux, optional on macOS
      return is_linux or (is_mac and vim.fn.exists('$SSH_CONNECTION') == 1)
    end,
    config = function()
      -- Minimal config - main setup in clipboard.lua
    end
  }
}
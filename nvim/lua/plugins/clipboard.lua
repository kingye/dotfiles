-- Clipboard plugin for OSC52 support on Linux systems
return {
  {
    'ojroques/nvim-osc52',
    lazy = true,
    -- Load on Linux systems (not macOS)
    cond = function()
      local is_mac = vim.fn.has('mac') == 1
      local is_linux = vim.fn.has('unix') == 1 and not is_mac
      return is_linux
    end,
    config = function()
      -- Configuration is handled in clipboard.lua
      -- This just ensures the plugin is available
    end
  }
}
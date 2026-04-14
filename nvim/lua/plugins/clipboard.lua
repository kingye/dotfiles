-- OSC52 plugin for clipboard over SSH on Linux
return {
  {
    'ojroques/nvim-osc52',
    lazy = true,
    -- Load on Linux systems
    cond = function()
      local is_mac = vim.fn.has('mac') == 1
      local is_linux = vim.fn.has('unix') == 1 and not is_mac
      return is_linux
    end,
    config = function()
      -- Configuration handled in clipboard.lua
    end
  }
}
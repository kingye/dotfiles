-- Optional clipboard plugin for OSC52 support
-- Only loads when needed on Linux systems with Tmux
return {
  {
    'ojroques/nvim-osc52',
    lazy = true,
    cond = function()
      -- Only load on Linux (not macOS) when in Tmux
      local is_mac = vim.fn.has('mac') == 1
      local is_linux = vim.fn.has('unix') == 1 and not is_mac
      local in_tmux = vim.fn.exists('$TMUX') == 1
      
      return is_linux and in_tmux
    end,
    config = function()
      -- Minimal config, setup happens in clipboard.lua
      -- This ensures the plugin is available when needed
    end,
    init = function()
      -- Ensure the plugin loads early enough
      vim.g.loaded_osc52 = 1
    end
  }
}
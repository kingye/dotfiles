-- Intelligent clipboard configuration for macOS/Linux with Tmux support
-- Works on both systems without breaking existing functionality
local M = {}

function M.setup()
  local is_mac = vim.fn.has('mac') == 1
  local is_linux = vim.fn.has('unix') == 1 and not is_mac
  local in_tmux = vim.fn.exists('$TMUX') == 1
  local term = vim.env.TERM or ""
  local wezterm = vim.env.WEZTERM_EXECUTABLE ~= nil
  
  -- Check if we're likely in a terminal with OSC52 support
  local has_osc52_support = term:match("wezterm") 
    or term:match("iterm") 
    or term:match("xterm")
    or wezterm
  
  -- Always set clipboard to unnamedplus as base
  vim.opt.clipboard = 'unnamedplus'
  
  if is_mac then
    -- macOS: Use pbcopy/pbpaste (should already work)
    vim.notify("Using macOS clipboard (pbcopy/pbpaste)", vim.log.levels.INFO)
    
  elseif is_linux and in_tmux then
    -- Linux cloud with Tmux
    if has_osc52_support then
      -- Try to use OSC52 if terminal supports it
      vim.notify("Linux cloud with Tmux: Using OSC52 clipboard over SSH", vim.log.levels.INFO)
    else
      -- No OSC52 support, use Tmux buffer fallback
      M.setup_tmux_fallback()
    end
  else
    -- Other cases (Linux without Tmux, etc.)
    vim.notify("Using system clipboard", vim.log.levels.INFO)
  end
end

function M.setup_tmux_fallback()
  -- Setup Tmux buffer as clipboard fallback
  vim.g.clipboard = {
    name = 'tmux-buffer',
    copy = {
      ['+'] = function(lines)
        vim.fn.system('tmux load-buffer -', table.concat(lines, '\n'))
      end,
      ['*'] = function(lines)
        vim.fn.system('tmux load-buffer -', table.concat(lines, '\n'))
      end,
    },
    paste = {
      ['+'] = function()
        return vim.split(vim.fn.system('tmux save-buffer -'), '\n')
      end,
      ['*'] = function()
        return vim.split(vim.fn.system('tmux save-buffer -'), '\n')
      end,
    },
  }
  vim.opt.clipboard = 'unnamedplus'
  vim.notify("Using Tmux buffer as clipboard", vim.log.levels.INFO)
end

-- Add keymaps for manual clipboard operations
function M.setup_keymaps()
  local map = vim.keymap.set
  
  -- Universal yank/paste (works everywhere)
  map({'n', 'v'}, '<leader>y', '"+y', { desc = "Yank to clipboard" })
  map('n', '<leader>p', '"+p', { desc = "Paste from clipboard" })
  map('x', '<leader>p', '"_d"+p', { desc = "Paste from clipboard (replace)" })
  
  -- Tmux-specific operations (only when in Tmux)
  if vim.fn.exists('$TMUX') == 1 then
    map({'n', 'v'}, '<leader>yt', function()
      vim.cmd('w !tmux load-buffer -')
      vim.notify("Yanked to Tmux buffer", vim.log.levels.INFO)
    end, { desc = "Yank to Tmux buffer" })
    
    map('n', '<leader>pt', function()
      vim.cmd('r !tmux save-buffer -')
    end, { desc = "Paste from Tmux buffer" })
  end
end

return M
-- Intelligent clipboard configuration for macOS/Linux with Tmux support
-- Works on both systems without breaking existing functionality
local M = {}

function M.setup()
  local is_mac = vim.fn.has('mac') == 1
  local is_linux = vim.fn.has('unix') == 1 and not is_mac
  
  -- Always set clipboard to unnamedplus as base
  vim.opt.clipboard = 'unnamedplus'
  
  if is_mac then
    -- macOS: Use pbcopy/pbpaste (should already work)
    vim.notify("Using macOS clipboard (pbcopy/pbpaste)", vim.log.levels.INFO)
  elseif is_linux then
    -- Linux: Always try OSC52 for SSH clipboard
    M.setup_osc52()
  end
end

function M.setup_osc52()
  -- Try to load OSC52 plugin
  local ok, osc52 = pcall(require, 'osc52')
  
  if ok then
    -- OSC52 available - configure it
    osc52.setup({
      max_length = 0,
      silent = false,
      trim = false,
      tmux_passthrough = true,
    })
    
    -- Set OSC52 as clipboard provider
    local function copy(lines, _)
      return osc52.copy(table.concat(lines, '\n'))
    end
    
    local function paste()
      -- OSC52 is copy-only, use terminal buffer for paste
      return {vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('')}
    end
    
    vim.g.clipboard = {
      name = 'osc52',
      copy = {['+'] = copy, ['*'] = copy},
      paste = {['+'] = paste, ['*'] = paste},
    }
    
    -- Auto-copy on yank to clipboard register
    vim.api.nvim_create_autocmd('TextYankPost', {
      callback = function()
        if vim.v.event.operator == 'y' and vim.v.event.regname == '+' then
          osc52.copy_register('+')
        end
      end,
    })
    
    vim.notify("✓ OSC52 clipboard enabled for SSH", vim.log.levels.INFO)
  else
    -- OSC52 not available - check why and provide helpful message
    local in_tmux = vim.fn.exists('$TMUX') == 1
    
    if in_tmux then
      vim.notify("⚠ OSC52 plugin not loaded. Using Tmux buffer only", vim.log.levels.WARN)
      vim.notify("   Run ':Lazy sync' to install plugins", vim.log.levels.INFO)
      M.setup_tmux_fallback()
    else
      vim.notify("⚠ OSC52 plugin not loaded and not in tmux", vim.log.levels.WARN)
      vim.notify("   Run ':Lazy sync' to install plugins", vim.log.levels.INFO)
    end
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
  
  -- Test OSC52 clipboard with better diagnostics
  map('n', '<leader>yc', function()
    local ok, osc52 = pcall(require, 'osc52')
    if ok then
      -- Test OSC52 copy
      local text = "OSC52 Test: " .. os.date("%H:%M:%S")
      osc52.copy(text)
      vim.notify("✓ Test copied via OSC52: " .. text, vim.log.levels.INFO)
      print("\n=== OSC52 Test ===")
      print("1. Copied text: " .. text)
      print("2. Try pasting locally with Cmd+V")
      print("3. If it works, OSC52 is configured correctly")
    else
      print("\n=== OSC52 Diagnostic ===")
      print("✗ OSC52 plugin not loaded")
      print("  - Is the plugin installed? Run :Lazy sync")
      print("  - Are you on Linux with Tmux?")
      print("  - Check: :Lazy show osc52")
      vim.notify("OSC52 plugin not available. Run :Lazy sync", vim.log.levels.ERROR)
    end
  end, { desc = "Test OSC52 clipboard" })
end

return M
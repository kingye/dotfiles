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
    print("OSC52: Configuring plugin...")
    
    -- Configure OSC52
    osc52.setup({
      max_length = 0,
      silent = false,
      trim = false,
      tmux_passthrough = true,
    })
    
    -- Test OSC52 works
    print("OSC52: Testing copy...")
    local test_result = osc52.copy("OSC52 Test from setup")
    print("OSC52: Copy result:", test_result)
    
    -- Setup OSC52 as clipboard provider (simpler approach)
    local function copy_to_osc52(lines, _)
      local text = table.concat(lines, '\n')
      print("OSC52: Copying text (length: " .. #text .. ")")
      return osc52.copy(text)
    end
    
    vim.g.clipboard = {
      name = 'osc52',
      copy = {
        ['+'] = copy_to_osc52,
        ['*'] = copy_to_osc52,
      },
      paste = {
        ['+'] = function()
          -- OSC52 is copy-only, fall back to terminal paste
          return {vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('')}
        end,
        ['*'] = function()
          return {vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('')}
        end,
      },
    }
    
    -- Set clipboard option (this enables OSC52 integration)
    vim.opt.clipboard = 'unnamedplus'
    
    -- Auto-copy on yank to clipboard register
    vim.api.nvim_create_autocmd('TextYankPost', {
      callback = function(event)
        if event.operator == 'y' and event.regname == '+' then
          print("OSC52: Auto-copying yanked text")
          osc52.copy_register('+')
        end
      end,
    })
    
    print("✓ OSC52 clipboard configured")
    
  else
    print("✗ OSC52 plugin not available")
    local in_tmux = vim.fn.exists('$TMUX') == 1
    
    if in_tmux then
      print("⚠ Using Tmux buffer fallback")
      M.setup_tmux_fallback()
    else
      print("⚠ No clipboard support available")
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
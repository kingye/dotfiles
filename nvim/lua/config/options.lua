-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Explicitly set leader key (LazyVim sets this by default, but being explicit helps with VSCode)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- OSC 52 clipboard for Linux SSH/tmux (nvim 0.10+ built-in)
-- LazyVim sets clipboard="" when SSH_CONNECTION is detected, and defers
-- clipboard restore to VeryLazy. But tmux inhibits OSC 52 auto-detection.
-- Fix: force OSC 52 provider, then set unnamedplus after VeryLazy fires.
if vim.fn.has("mac") == 0 and vim.fn.has("unix") == 1 then
  vim.g.clipboard = "osc52"
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      vim.schedule(function()
        vim.opt.clipboard = "unnamedplus"
      end)
    end,
  })
end

-- VSCode-specific configuration
if vim.g.vscode then
  -- Ensure space works immediately in insert mode and other non-normal modes
  -- This is handled by the neovim extension, but we make sure leader is set
  vim.opt.timeoutlen = 500 -- Shorter timeout for better responsiveness
end

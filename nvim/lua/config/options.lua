-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Explicitly set leader key (LazyVim sets this by default, but being explicit helps with VSCode)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- VSCode-specific configuration
if vim.g.vscode then
  -- Ensure space works immediately in insert mode and other non-normal modes
  -- This is handled by the neovim extension, but we make sure leader is set
  vim.opt.timeoutlen = 500 -- Shorter timeout for better responsiveness
end

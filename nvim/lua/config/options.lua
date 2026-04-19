-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Explicitly set leader key (LazyVim sets this by default, but being explicit helps with VSCode)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- OSC 52 clipboard for Linux SSH/tmux (nvim 0.10+ built-in)
-- On macOS, LazyVim's default unnamedplus + pbcopy just works.
-- On Linux without a display server, use OSC 52 to sync yank with local terminal.
if vim.fn.has("mac") == 0 and vim.fn.has("unix") == 1 then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end

-- VSCode-specific configuration
if vim.g.vscode then
  -- Ensure space works immediately in insert mode and other non-normal modes
  -- This is handled by the neovim extension, but we make sure leader is set
  vim.opt.timeoutlen = 500 -- Shorter timeout for better responsiveness
end

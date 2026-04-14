-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

map("i", "jk", "<ESC>")

--  not suspend nvim by ctrl-z
map({ 'n', 'i' }, '<C-z>', '<nop>', { noremap = true })

-- Terminal keymaps (only for non-VSCode)
if not vim.g.vscode then
  map("n", "<leader>t|", "<cmd>vsplit | terminal<cr>", { desc = "Vsplit terminal" })
  map("n", "<leader>t-", "<cmd>split | terminal<cr>", { desc = "Hsplit terminal" })
end

-- Load smart pane navigation (Neovim <-> WezTerm)
require('config.wezterm-nav')

-- Load VSCode-specific keymaps
require('config.vscode-keymaps')


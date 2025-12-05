-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

map("i", "jk", "<ESC>")

--  not suspend nvim by ctrl-z
map({'n', 'i'}, '<C-z>', '<nop>', {noremap = true})

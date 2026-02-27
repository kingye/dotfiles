-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

function Transparent()
  vim.cmd([[
hi Normal guibg=NONE ctermbg=NONE
hi NormalNC guibg=NONE ctermbg=NONE
hi NormalFloat guibg=NONE ctermbg=NONE
hi FloatBorder guibg=NONE ctermbg=NONE
hi SignColumn guibg=NONE ctermbg=NONE
hi StatusLine guibg=NONE ctermbg=NONE
hi StatusLineNC guibg=NONE ctermbg=NONE
hi VertSplit guibg=NONE ctermbg=NONE
hi TabLine guibg=NONE ctermbg=NONE
hi TabLineFill guibg=NONE ctermbg=NONE
hi TabLineSel guibg=NONE ctermbg=NONE
hi terminal guibg=NONE ctermbg=NONE
hi Pmenu guibg=NONE ctermbg=NONE
hi PmenuSel guibg=NONE ctermbg=NONE
hi NeoTreeNormal guibg=NONE ctermbg=NONE
hi NeoTreeNormalNC guibg=NONE ctermbg=NONE
hi NeoTreeWinSeparator guibg=NONE ctermbg=NONE
hi NeoTreeEndOfBuffer guibg=NONE ctermbg=NONE
hi EndOfBuffer guibg=NONE ctermbg=NONE
]])
  vim.api.nvim_set_hl(0, "SnacksPicker", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksNormal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksNormalNC", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksWinBar", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksWinBarNC", { bg = "NONE" })
end

Transparent()

-- Reapply transparency on buffer enter
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = Transparent,
})

-- Reapply transparency when terminal is opened
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = Transparent,
})

-- Reapply transparency when entering a terminal window (for toggling)
vim.api.nvim_create_autocmd("WinEnter", {
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "terminal" then
      Transparent()
    end
  end,
})

-- Also apply on ColorScheme change (in case terminal toggle triggers this)
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = Transparent,
})

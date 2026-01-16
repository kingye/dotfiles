-- VSCode-specific plugin configuration
-- This file disables plugins that don't work well or are redundant in VSCode
if not vim.g.vscode then
  return {}
end

-- When running in VSCode, disable these plugins
return {
  -- UI Components (VSCode has its own UI)
  { "folke/snacks.nvim", enabled = false },
  { "nvim-lualine/lualine.nvim", enabled = false },
  { "akinsho/bufferline.nvim", enabled = false },
  { "folke/noice.nvim", enabled = false },
  { "rcarriga/nvim-notify", enabled = false },
  { "stevearc/dressing.nvim", enabled = false },
  { "folke/edgy.nvim", enabled = false },

  -- File/Buffer Navigation (VSCode has Command Palette & Explorer)
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  { "nvim-tree/nvim-tree.lua", enabled = false },
  { "nvim-telescope/telescope.nvim", enabled = false },

  -- Terminal/Window Management (not applicable in VSCode)
  { "christoomey/vim-tmux-navigator", enabled = false },
  { "akinsho/toggleterm.nvim", enabled = false },

  -- Dashboard/Startup Screens (not needed in VSCode)
  { "goolord/alpha-nvim", enabled = false },
  { "echasnovski/mini.starter", enabled = false },
  { "nvimdev/dashboard-nvim", enabled = false },

  -- Git UI (VSCode has built-in Git integration)
  { "lewis6991/gitsigns.nvim", enabled = false },
  { "sindrets/diffview.nvim", enabled = false },
  { "NeogitOrg/neogit", enabled = false },

  -- Indent guides (VSCode has its own)
  { "lukas-reineke/indent-blankline.nvim", enabled = false },
  { "echasnovski/mini.indentscope", enabled = false },

  -- Session management (VSCode manages workspaces)
  { "folke/persistence.nvim", enabled = false },

  -- Colorschemes (VSCode uses its own themes)
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },

  -- Note: Keep enabled for better editing experience:
  -- - nvim-treesitter (better syntax highlighting)
  -- - nvim-cmp (autocompletion)
  -- - Text objects and motions (surround, comment, etc.)
  -- - LSP configurations (optional - you can disable if you prefer VSCode's LSP)
}

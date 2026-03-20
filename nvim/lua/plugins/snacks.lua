return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { section = "keys",   gap = 1, padding = 1 },
          { section = "startup" },
          {
            section = "terminal",
            cmd = "chafa ~/.config/nvim/nailong.jpg --format symbols --symbols vhalf --stretch; sleep .1",
            -- cmd = "ascii-image-converter ~/.config/nvim/nailong.jpg -C -c",
            random = 10,
            pane = 2,
            indent = 4,
            height = 30
          },
        },
      },
      terminal = {
        enabled = true,
        win = {
          position = "float",
          border = "rounded",
          width = 0.9,
          height = 0.9,
        },
      },
      picker = {
        hidden = true,
        ignored = true, -- show files ignored by git like node_modules
        exclude = { ".git", ".DS_Store" },
        sources = {
          files = {
            hidden = true,  -- Show hidden/dotfiles
            ignored = true, -- show files ignored by git like node_modules
            exclude = { ".git", "gen" },
          },
          grep = {
            hidden = true, -- Also search in hidden files
            ignored = true,
            exclude = { "node_modules", ".git" },
          },
        },
      },
      zen = {
        enabled = true,
        win = {
          border = "rounded",
        },
      },
    },
  },
}

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cds = {
          cmd = { "cds-lsp", "--stdio" },
          filetypes = { "cds" },
          root_dir = vim.fs.dirname(vim.fs.find({".cdsrc.json",  "package.json"}, {upward = true})[1]),
          settings = {},
        },
      },
    },
  },
}

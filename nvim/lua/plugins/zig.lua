return {
  { "ziglang/zig.vim" },
  {
    "nvim-lspconfig",
    opts = {
      servers = {
        zls = {
          -- This points NeoVim to use the active version
          -- of ZLS set by ZVM
          cmd = { vim.fn.expand("$HOME/.zvm/bin/zls") },
        },
      },
    },
  },
}

return {
  "stevearc/conform.nvim",
  event = "BufReadPre",
  opts = {},
  config = function(_, opts)
    require("conform").setup({
      formatters_by_ft = {
        -- Conform will run the first available formatter
        typescript = { "eslint", "eslint_d", "prettier", stop_after_first = true, timeout_ms=10000},
        javascript = { "eslint", "eslint_d", "prettier", stop_after_first = true, timeout_ms=10000 },
        cds = { "eslint", "eslint_d", "prettier", stop_after_first = true, timeout_ms=10000 },
      },
    })
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(args)
        require("conform").format({ bufnr = args.buf })
      end,
    })
  end,
}

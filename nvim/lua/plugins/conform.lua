return {
  "stevearc/conform.nvim",
  event = "BufReadPre",
  opts = {},
  config = function(_, opts)
    require("conform").setup({
      formatters_by_ft = {
        -- Conform will run the first available formatter
        typescript = { "eslint", "eslint_d", "prettier", stop_after_first = true, timeout_ms=5000},
        javascript = { "eslint", "eslint_d", "prettier", stop_after_first = true, timeout_ms=5000 },
        cds = { "eslint", "eslint_d", "prettier", stop_after_first = true, timeout_ms=5000 },
      },
      format_on_save = function ()
        if vim.g.disable_autoformat then
          return
        end
        return {
          async = true,
          lsp_fallback = true,
          timeout_ms = 500,
        }
      end
    })
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   pattern = "*",
    --   callback = function(args)
    --     require("conform").format({ bufnr = args.buf })
    --   end,
    -- })
  end,
}

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- setup intelligent clipboard configuration
require("config.clipboard").setup()

-- setup treesitter parser for filetype cds
-- followed cmmand needs to be executed
-- :TSInstall cds 
-- for syntax highlighting needs followed
-- git clone https://github.com/cap-js-community/tree-sitter-cds
-- copy scm files in queries folder into ~/.local/share/nvim/site/queries/cds/
vim.api.nvim_create_autocmd("User", {
	pattern = "TSUpdate",
	callback = function()
		require("nvim-treesitter.parsers").cds = {
      install_info = {
        url = "https://github.com/cap-js-community/tree-sitter-cds.git",
        files = { "src/parser.c", "src/scanner.c" },
        branch = "main",
        generate = false,
        generate_requires_npm = false,
        requires_generate_from_grammar = false,
        queries = "queries/cds",
      },
      filetype = "cds", -- if filetype does not match the parser name

      -- additional filetypes that use this parser
      used_by = { "cdl", "hdbcds" },
		}
	end,
})

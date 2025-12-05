return {
  "olimorris/codecompanion.nvim",
  url = "https://gitcode.com/gh_mirrors/co/codecompanion.nvim.git",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- "nvim-telescope/telescope.nvim"
  },
  config = function()
    require("codecompanion").setup({
      display = {
        chat = {
          window = {
            width = 0.3,
          },
        },
      },
      -- tools = {
      --   ["mcp"] = {
      --     callback = require("mcphub.extensions.codecompanion"),
      --     description = "Call tools and resources from the MCP Servers",
      --     opts = {
      --       user_approval = true,
      --     },
      --   },
      -- },
      adapters = {
        siliconflow_v3 = function()
          return require("codecompanion.adapters").extend("deepseek", {
            name = "siliconflow_v3",
            url = "https://api.siliconflow.cn/v1/chat/completions",
            env = {
              api_key = function()
                return os.getenv("SILICONFLOW_API_KEY")
              end,
            },
            schema = {
              model = {
                default = "Pro/deepseek-ai/DeepSeek-V3",
                choices = {
                  ["Pro/deepseek-ai/DeepSeek-V3"] = { opts = { can_reason = false } },
                  ["deepseek-ai/DeepSeek-R1"] = { opts = { can_reason = true } },
                },
              },
            },
          })
        end,
        siliconflow_r1 = function()
          return require("codecompanion.adapters").extend("deepseek", {
            name = "siliconflow_r1",
            url = "https://api.siliconflow.cn/v1/chat/completions",
            env = {
              api_key = function()
                return os.getenv("SILICONFLOW_API_KEY")
              end,
            },
            schema = {
              model = {
                default = "deepseek-ai/DeepSeek-R1",
                choices = {
                  ["deepseek-ai/DeepSeek-R1"] = { opts = { can_reason = true } },
                  "deepseek-ai/DeepSeek-V3",
                },
              },
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = "siliconflow_v3" },
        inline = { adapter = "siliconflow_v3" },
      },
      opts = {
        language = "Chinese",
      },
    })
    vim.keymap.set({ "n", "v", "x" }, "<leader>ccc", function()
      require("codecompanion").toggle()
    end, { desc = "toggle code codecompanion" })
    vim.keymap.set({ "n", "v", "x" }, "<leader>cp", ":CodeCompanionActions<CR>", { desc = "codecompanion action" })
  end,
}

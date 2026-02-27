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
        action_palette = {
          width = 95,
          height = 10,
          prompt = "Prompt ",                -- Prompt used for interactive LLM calls
          provider = "default",              -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
          opts = {
            show_preset_actions = true,      -- Show the preset actions in the action palette?
            show_preset_prompts = true,      -- Show the preset prompts in the action palette?
            title = "CodeCompanion actions", -- The title of the action palette
          },
        },
      },
      adapters = {
        http = {
          qwen_coder = function()
            return require("codecompanion.adapters").extend("openai", {
              name = "qwen_coder",
              url = "https://api.siliconflow.cn/v1/chat/completions",
              env = {
                api_key = function()
                  return os.getenv("SILICONFLOW_API_KEY")
                end,
              },
              schema = {
                model = {
                  default = "Qwen/Qwen3-Coder-480B-A35B-Instruct",
                },
              },
              handlers = {
                supports_tools = true,
              },
            })
          end,
          siliconflow_v3 = function()
            return require("codecompanion.adapters").extend("openai", {
              name = "siliconflow_v3",
              url = "https://api.siliconflow.cn/v1/chat/completions",
              env = {
                api_key = function()
                  return os.getenv("SILICONFLOW_API_KEY")
                end,
              },
              schema = {
                model = {
                  default = "Pro/deepseek-ai/DeepSeek-V3.2",
                },
              },
              handlers = {
                supports_tools = true,
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
        }
      },
      strategies = {
        chat = { adapter = "qwen_coder" },
        inline = { adapter = "qwen_coder" },
      },
      opts = {
        language = "Chinese",
      },
    })
    vim.keymap.set({ "n", "v", "x" }, "<leader>ccc", function()
      require("codecompanion").toggle()
    end, { desc = "toggle code codecompanion" })
    vim.keymap.set({ "n", "v", "x" }, "<leader>cp", ":CodeCompanionActions<CR>", { desc = "codecompanion action" })

    -- Send current file to CodeCompanion for analysis
    vim.keymap.set({ "n", "v" }, "<leader>ccf", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")

      require("codecompanion").chat({
        messages = {
          {
            role = "user",
            content = "Here is the current file (" .. bufname .. "):\n\n```\n" .. content .. "\n```\n\nPlease analyze this file and tell me what it does.",
          },
        },
      })
    end, { desc = "Analyze current file with CodeCompanion" })
  end,
}

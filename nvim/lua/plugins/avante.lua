return {
  "yetone/avante.nvim",
  build = "make",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  --@module 'avante'
  -- @type avante.Config
  opts = {
    auto_confirm = true,
    -- disabled_tools = {
    --   "list_files", -- Built-in file operations
    --   "search_files",
    --   "read_file",
    --   "create_file",
    --   "rename_file",
    --   "delete_file",
    --   "create_dir",
    --   "rename_dir",
    --   "delete_dir",
    --   "bash", -- Built-in terminal access
    -- },
    -- system_prompt as function ensures LLM always has latest MCP server state
    -- This is evaluated for every message, even in existing chats
    system_prompt = function()
      local hub = require("mcphub").get_hub_instance()
      return hub and hub:get_active_servers_prompt() or ""
    end,

    -- Using function prevents requiring mcphub before it's loaded
    custom_tools = function()
      return {
        require("mcphub.extensions.avante").mcp_tool(),
      }
    end,

    input = {
      provider = "snacks",
      provider_opts = {
        -- Additional snacks.input options
        title = "Avante Input",
        icon = " ",
      },
    },
    selector = {
      --- @alias avante.SelectorProvider "native" | "fzf_lua" | "mini_pick" | "snacks" | "telescope" | fun(selector: avante.ui.Selector): nil
      --- @type avante.SelectorProvider
      provider = "snacks",
      -- Options override for custom providers
      provider_opts = {},
    },
    provider = "copilot",
    auto_suggestions_provider = "copilot",
    providers = {
      copilot = {
        model = "claude-sonnet-4",
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 20480,
        },
      },
      claude = {
        endpoint = "https://api.githubcopilot.com",
        model = "claude-sonnet-4",
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 20480,
        },
      },
      openai = {
        endpoint = "https://api.githubcopilot.com",
        model = "gpt-4o",
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0,
          max_tokens = 20480,
        },
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "folke/snacks.nvim", -- for input provider snacks
    {
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      opts = {},
    },
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}

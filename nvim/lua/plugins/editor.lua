return {
  ---@type LazySpec
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = {
      "folke/snacks.nvim",
    },
    keys = {
      {
        "<leader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
    },
    ---@type YaziConfig | {}
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
    -- 👇 if you use `open_for_directories=true`, this is recommended
    init = function()
      -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
      -- vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({
            action = "focus",
            position = "float",
            reveal_force_cwd = true, -- change cwd without asking if needed
            toggle = true,
          })
        end,
      },
    },
    opts = {
      default_component_configs = {
        type = {
          enabled = false,
        },
        last_modified = {
          enabled = false,
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            ".git",
          },
        },
        follow_current_file = { enabled = true },
        bind_to_cwd = false,
        use_libuv_file_watcher = true,
      },
      find_args = { -- you can specify extra args to pass to the find command.
        fd = {
          "--exclude",
          ".git",
          "--exclude",
          "node_modules",
          "--exclude",
          ".next",
        },
      },
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      window = {
        mappings = {
          ["P"] = { "toggle_preview", config = { use_float = true } },
        },
        position = "float", -- left, right, top, bottom, float, current

        -- popup = { -- settings that apply to float position only
        --   size = {
        --     height = "80%",
        --     width = "50%",
        --   },
        --   position = "50%", -- 50% means center it
        --   title = function(state) -- format the text that appears at the top of a popup window
        --     return "Neo-tree " .. state.name:gsub("^%l", string.upper)
        --   end,
        --   -- you can also specify border here, if you want a different setting from
        --   -- the global popup_border_style.
        -- },
        -- same_level = true,
      },
      popup_border_style = "rounded", -- "NC", "double", "none", "rounded", "shadow", "single" or "solid"
    },
  },
}

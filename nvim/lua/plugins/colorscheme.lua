return {
  {
    "catppuccin/nvim",
    -- lazy = false,
    name = "catppuccin",
    -- priority = 1000,
    opts = {
      transparent_background = false,
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    -- lazy = false,
    opts = {
      neotree = true,
      cmp = true,
      gitsigns = true,
      markdown = true,
      mini = true,
      noice = true,
      notify = true,
      telescope = true,
      treesitter = true,
      which_key = true,
      dark_variant = "main",
      enable = {
        legacy_highlights = false,
        migrations = false,
      },
      styles = {
        transparency = true,
        italic = false,
      },
    },
  },
  {
    "mellow-theme/mellow.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.mellow_italic_functions = true
      vim.g.mellow_bold_functions = true
      vim.g.mellow_transparent = true
      vim.g.mellow_highlight_overrides = {
        ["NormalNC"] = { link = "Normal" },
      }

      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.edge_enable_italic = true
    end,
  },
  {
    "hardhackerlabs/theme-vim",
    name = "hardhacker",
    -- lazy = false,
    -- priority = 1000,
    config = function()
      vim.g.hardhacker_hide_tilde = 1
      vim.g.hardhacker_keyword_italic = 1
      vim.g.hardhacker_transparent_background = 1
    end,
  },
  {
    "Yazeed1s/oh-lucy.nvim",
    -- lazy = false,
    -- priority = 1000,
    config = function()
      vim.g.oh_lucy_transparent_background = true
      vim.g.oh_lucy_evening_transparent_background = true
    end,
  },
  {
    "ramojus/mellifluous.nvim",
    -- version = "v0.*", -- uncomment for stable config (some features might be missed if/when v1 comes out)
    config = function()
      require("mellifluous").setup({
        colorset = "mountain",
        transparent_background = {
          enabled = true,
          telescope = false,
        },
      })
    end,
  },
  {
    "vague2k/vague.nvim",
    config = function()
      require("vague").setup({
        transparent = true,
      })
    end,
  },
}

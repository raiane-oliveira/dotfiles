local transparency = true

local future_themes = {
  {
    "cdmill/neomodern.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("neomodern").setup({
        -- optional configuration here
      })
      require("neomodern").load()
    end,
  },
  {
    "everviolet/nvim",
    name = "evergarden",
    priority = 1000, -- Colorscheme plugin is loaded first before any other plugins
    opts = {
      theme = {
        variant = "winter", -- 'winter'|'fall'|'spring'|'summer'
        accent = "green",
      },
      editor = {
        transparent_background = transparency,
        sign = { color = "none" },
        float = {
          color = "mantle",
          solid_border = false,
        },
        completion = {
          color = "surface0",
        },
      },
    },
  },
  {
    "vague2k/vague.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other plugins
    opts = {
      transparent = transparency,
    },
  },
  {
    "rebelot/kanagawa.nvim",
    opts = {
      transparent = transparency,
    },
  },
}

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "mellow",
    },
  },
  -- Using lazy.nvim
  {
    "metalelf0/black-metal-theme-neovim",
    lazy = false,
    priority = 1000,
    config = function()
      require("black-metal").setup({
        -- optional configuration here
        transparent = transparency,
      })
      -- require("black-metal").load()
    end,
  },
  {
    "ramojus/mellifluous.nvim",
    opts = {
      colorset = "mountain",
      transparent_background = {
        enabled = transparency,
      },
    },
  },
  {
    "mellow-theme/mellow.nvim",
    priority = 1000,
    config = function()
      local c = require("mellow.colors")

      vim.g.mellow_italic_functions = true
      vim.g.mellow_bold_functions = true
      vim.g.mellow_transparent = transparency
      vim.g.mellow_highlight_overrides = {

        -- Diagnostics
        ["DiagnosticUnderlineError"] = { fg = c.red, underline = true },
        ["DiagnosticUnderlineWarn"] = { fg = c.yellow, underline = true },
        ["DiagnosticUnderlineInfo"] = { fg = c.blue, underline = true },
        ["DiagnosticUnderlineHint"] = { fg = c.cyan, underline = true },

        -- Neovim's built-in language server client
        ["LspReferenceWrite"] = { fg = c.blue, underline = true },
        ["LspReferenceText"] = { fg = c.blue, underline = true },
        ["LspReferenceRead"] = { fg = c.blue, underline = true },
        ["LspSignatureActiveParameter"] = { fg = c.yellow, bold = true },
      }

      vim.g.edge_enable_italic = true
    end,
  },
}

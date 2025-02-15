local transparency = true

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "mellow",
    },
  },
  {
    "mellow-theme/mellow.nvim",
    -- lazy = false,
    priority = 1000,
    config = function()
      vim.g.mellow_italic_functions = true
      vim.g.mellow_bold_functions = true
      vim.g.mellow_transparent = transparency
      vim.g.mellow_highlight_overrides = {
        ["NormalNC"] = { link = "Normal" },
      }

      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.edge_enable_italic = true
    end,
  },
}

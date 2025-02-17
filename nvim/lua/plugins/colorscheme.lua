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

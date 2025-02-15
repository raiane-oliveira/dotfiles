return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          border = "single",
          draw = {
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                -- Optionally, you may also use the highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
          },
        },
        documentation = { window = { border = "single" } },
        list = { selection = { preselect = true, auto_insert = false } },
      },
      signature = { window = { border = "single" } },
      keymap = {
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "snippet_forward",
          "fallback",
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>/", false },
      {
        "<leader>fw",
        function()
          Snacks.picker.grep()
        end,
        desc = "Live Grep",
      },
    },
  },
}

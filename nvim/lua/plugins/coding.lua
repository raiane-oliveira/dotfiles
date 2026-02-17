return {
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local luasnip = require("luasnip")

      luasnip.add_snippets("typescriptreact", require("snippets.react"))
      luasnip.add_snippets("javascriptreact", require("snippets.react"))
      luasnip.add_snippets("all", require("snippets.lorem"))
    end,
  },
  {
    "saghen/blink.cmp",
    dependencies = {
      "Kaiser-Yang/blink-cmp-avante",
      "rafamadriz/friendly-snippets",
    },
    opts = {
      sources = {
        -- Add 'avante' to the list
        default = { "avante", "lsp", "path", "snippets", "buffer" },
        providers = {
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
            opts = {
              -- options for blink-cmp-avante
            },
          },
        },
      },
      snippets = {
        preset = "luasnip",
      },
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
        documentation = { window = { border = "single" }, auto_show = true },
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
    opts = {
      picker = {
        sources = {
          files = {
            -- Permite que o picker mostre arquivos ocultos (como .env)
            hidden = true,
            ignored = true, -- Inclui arquivos ignorados pelo Git (como .env)
            -- Define os diretórios a serem excluídos da pesquisa
            exclude = {
              "**/node_modules/*",
              "**/.git/*",
              "**/build/*",
              "**/dist/*",
              "**/.next/*",
              "**/target/*",
            },
          },
          grep = {
            hidden = true, -- Permite a busca em arquivos ocultos (como .env)
            ignored = true, -- Inclui arquivos ignorados pelo Git (como .env)
            exclude = {
              "**/node_modules/*",
              "**/.git/*",
              "**/build/*",
              "**/dist/*",
              "**/.next/*",
              "**/playwright-report/*",
              "**/target/*",
              "**/target/classes/*",
            },
          },
        },
        formatters = {
          file = {
            truncate = 80,
          },
        },
        layout = {
          preset = "telescope", -- [default|dropdown|ivy|select|sidebar|telescope|vertical|vscode]
          preview = false,
          layout = {
            backdrop = false,
            width = 0.5,
            min_width = 80,
            height = 0.5,
            min_height = 3,
          },
        },
      },
    },
  },
}

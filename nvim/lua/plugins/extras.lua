return {
  {
    "nvim-mini/mini.comment",
    config = function()
      require("mini.comment").setup({
        mappings = {
          comment = "<leader>/",
          comment_line = "<leader>/",
          comment_visual = "<leader>/",
          textobject = "<leader>/",
        },
      })
    end,
  },
  {
    "nvim-mini/mini.surround",
    opts = {
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`
      },
    },
  },
  {
    "nvim-mini/mini.hipatterns",
    config = function()
      local hipatterns = require("mini.hipatterns")

      local rgba_color = function(_, match)
        local red, green, blue, alpha = match:match("rgba%((%d+), ?(%d+), ?(%d+), ?(%d*%.?%d*)%)")
        alpha = tonumber(alpha)
        if alpha == nil or alpha < 0 or alpha > 1 then
          return false
        end
        -- tonumber nas strings dos canais
        local hex = string.format(
          "#%02x%02x%02x",
          math.floor(tonumber(red) * alpha),
          math.floor(tonumber(green) * alpha),
          math.floor(tonumber(blue) * alpha)
        )
        return hipatterns.compute_hex_color_group(hex, "bg")
      end

      hipatterns.setup({
        highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color(),

          oklch_color = {
            pattern = "oklch%([%d%.]+%s+[%d%.]+%s+[%d%.]+%)",
            group = function(_, match)
              local l, c, h = match:match("oklch%(([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)%)")
              if not l then
                return false
              end
              l, c, h = tonumber(l), tonumber(c), tonumber(h)

              -- OKLCH → OKLab
              local hr = math.rad(h)
              local a = c * math.cos(hr)
              local b = c * math.sin(hr)

              -- OKLab → Linear sRGB
              local ll = l + 0.3963377774 * a + 0.2158037573 * b
              local mm = l - 0.1055613458 * a - 0.0638541728 * b
              local ss = l - 0.0894841775 * a - 1.2914855480 * b
              local r = ll ^ 3 * 4.0767416621 - mm ^ 3 * 3.3077115913 + ss ^ 3 * 0.2309699292
              local g = ll ^ 3 * -1.2684380046 + mm ^ 3 * 2.6097574011 - ss ^ 3 * 0.3413193965
              local bv = ll ^ 3 * -0.0041960863 - mm ^ 3 * 0.7034186147 + ss ^ 3 * 1.7076147010

              -- Gamma correction (linear → sRGB)
              local function to_srgb(v)
                v = math.max(0, math.min(1, v))
                if v <= 0.0031308 then
                  return v * 12.92
                end
                return 1.055 * v ^ (1 / 2.4) - 0.055
              end

              local hex = string.format(
                "#%02x%02x%02x",
                math.floor(to_srgb(r) * 255),
                math.floor(to_srgb(g) * 255),
                math.floor(to_srgb(bv) * 255)
              )
              return hipatterns.compute_hex_color_group(hex, "bg")
            end,
          },

          rgba_color = {
            pattern = "rgba%(%d+, ?%d+, ?%d+, ?%d*%.?%d*%)",
            group = rgba_color,
          },
        },
      })
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  { "wakatime/vim-wakatime", lazy = false },
  -- {
  --   "mistricky/codesnap.nvim",
  --   tag = "v2.0.0",
  --   opts = {
  --     show_line_number = false,
  --     snapshot_config = {
  --       watermark = {
  --         content = "@raiane-oliveira",
  --       },
  --       background = "#00000000",
  --     },
  --   },
  -- },
}

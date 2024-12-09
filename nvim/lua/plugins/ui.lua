return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
      },
    },
  },
  {
    "echasnovski/mini.indentscope",
    opts = {
      options = { try_as_border = true },
      draw = {
        animation = require("mini.indentscope").gen_animation.none(),
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
  },
}

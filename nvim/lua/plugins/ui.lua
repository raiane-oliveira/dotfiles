local dashboard_config = {
  preset = {
    header = {
      [[


     ███▄    █     ▒█████      ██▓    ▄████▄     ▓█████   
     ██ ▀█   █    ▒██▒  ██▒   ▓██▒   ▒██▀ ▀█     ▓█   ▀   
    ▓██  ▀█ ██▒   ▒██░  ██▒   ▒██▒   ▒▓█    ▄    ▒███     
    ▓██▒  ▐▌██▒   ▒██   ██░   ░██░   ▒▓▓▄ ▄██▒   ▒▓█  ▄   
    ▒██░   ▓██░   ░ ████▓▒░   ░██░   ▒ ▓███▀ ░   ░▒████▒  
    ░ ▒░   ▒ ▒    ░ ▒░▒░▒░    ░▓     ░ ░▒ ▒  ░   ░░ ▒░ ░  
    ░ ░░   ░ ▒░     ░ ▒ ▒░     ▒ ░     ░  ▒       ░ ░  ░  
       ░   ░ ░    ░ ░ ░ ▒      ▒ ░   ░              ░     
             ░        ░ ░      ░     ░ ░            ░  ░  
                                     ░                    ]],
    },
    keys = {
      {
        icon = " ",
        key = "c",
        desc = "Config",
        action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
      },
      { icon = " ", key = "s", desc = "Restore Session", section = "session" },
      { icon = " ", key = "q", desc = "Quit", action = ":qa" },
    },
  },

  sections = {
    -- {
    --   pane = 2,
    --   section = "terminal",
    --   cmd = "pokemon-colorscripts -r --no-title; sleep .1",
    --   height = 30,
    --   random = 10,
    --   indent = 4,
    -- },
    {
      pane = 1,
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      { section = "startup" },
    },
    -- {
    --   pane = 2,
    --   section = "keys",
    --   gap = 1,
    --   padding = 1,
    -- },
  },
}

return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = dashboard_config,
    },
  },
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
        -- animation = require("mini.indentscope").gen_animation.none(),
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      indent = {
        char = "",
        tab_char = "",
      },
    },
  },
}

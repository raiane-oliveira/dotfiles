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
      { icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
      { icon = " ", key = "s", desc = "Restore Session", section = "session" },
      { icon = " ", key = "q", desc = "Quit", action = ":qa" },

      --   Projects                                                p
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
    ---@type snacks.Config
    opts = {
      dashboard = dashboard_config,
      indent = {
        enabled = false,
      },
      explorer = {
        enabled = false,
      },
      zen = {
        enabled = false,
      },
      image = {},
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
}

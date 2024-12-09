local cmp = require("cmp")

return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    opts = {
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = {
        ["<Tab>"] = cmp.mapping.confirm(),
      },
    },
  },
  {
    "nvim-cmp",
    optional = true,
    dependencies = { "codeium.nvim" },
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "codeium",
        group_index = 1,
        priority = 100,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      auto_install = true,
      highlight = {
        enable = true,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = false,
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>/", false },
      { "<leader>fw", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },
      { "<leader><leader>", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
    },
  },
  {
    "ellisonleao/dotenv.nvim",
    opts = {
      enable_on_load = true, -- will load your .env file upon loading a buffer
      verbose = false, -- show error notification if .env file is not found and if .env is loaded
    },
  },
}

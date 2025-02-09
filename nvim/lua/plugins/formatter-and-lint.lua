return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- javascript = { "eslint_d", "prettierd", "biome" },
        javascriptreact = { "eslint_d", "prettierd", "biome" },
        -- typescript = { "eslint_d", "prettierd", "biome" },
        -- typescriptreact = { "biome", "eslint_d", stop_after_first = true },
        typescriptreact = { "eslint_d", "prettierd", "biome" },
        javascript = { "prettierd", "eslint_d", stop_after_first = true },
        typescript = { "eslint_d", "prettierd" },
        html = { "prettierd" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        -- javascript = { "biomejs" },
        -- javascriptreact = { "biomejs" },
        -- typescript = { "biomejs" },
        -- typescriptreact = { "biomejs" },

        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },

        dockerfile = { "hadolint" },
      },
    },
  },
}

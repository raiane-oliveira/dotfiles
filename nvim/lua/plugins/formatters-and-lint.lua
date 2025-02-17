local formatJSFiles = function(bufnr)
  local conform = require("conform")
  if conform.get_formatter_info("eslint_d", bufnr).available then
    return { "eslint_d" }
  elseif conform.get_formatter_config("biome", bufnr) then
    return { "biome" }
  else
    return { "prettierd" }
  end
end

return {
  {
    "stevearc/conform.nvim",
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        typescriptreact = formatJSFiles,
        javascriptreact = formatJSFiles,
        javascript = formatJSFiles,
        typescript = formatJSFiles,
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

local formatJSFiles = function(bufnr)
  local conform = require("conform")
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  local function eslint_d_ok()
    local info = conform.get_formatter_info("eslint_d", bufnr)
    if not info.available then
      return false
    end
    -- `available` só confirma que o binário existe e que HÁ um arquivo
    -- de config por perto -- não que ele é válido. Testamos de verdade:
    vim.fn.system({ "eslint_d", "--print-config", bufname })
    return vim.v.shell_error == 0
  end

  if eslint_d_ok() then
    return { "eslint_d" }
  end

  local biome_info = conform.get_formatter_info("biome", bufnr)
  if biome_info.available then
    return { "biome" }
  end

  return { "prettierd" }
end

return {
  {
    "stevearc/conform.nvim",
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        typescriptreact = { "prettierd" },
        javascriptreact = formatJSFiles,
        javascript = formatJSFiles,
        typescript = formatJSFiles,
        html = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        python = { "ruff" },
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

        python = { "ruff" },
      },
    },
  },
}

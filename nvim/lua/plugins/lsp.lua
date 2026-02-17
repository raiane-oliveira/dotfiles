return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Preserve your existing setup and inlay_hints
      opts.setup = {
        eslint = function()
          require("lazyvim.util").lsp.on_attach(function(client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == "tsserver" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
      }
      opts.inlay_hints = {
        enabled = false,
      }

      -- opts.keys = {
      -- }
    end,
    keys = {
      { "<leader>R", "<cmd>LspRestart<cr>", desc = "LSP Restart" },
    },
  },
  {
    "qvalentin/helm-ls.nvim",
    ft = "helm",
    opts = {
      yamlls = { path = "yaml-language-server" },
    },
  },
}

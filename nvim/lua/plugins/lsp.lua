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

      local keymaps = require("lazyvim.plugins.lsp.keymaps").get()
      table.insert(keymaps, { "<leader>R", "<cmd>LspRestart<cr>", desc = "LSP Restart" })
      opts.keys = keymaps
    end,
  },
}

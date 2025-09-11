return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
  opts = {
    extensions = {
      avante = {
        make_slash_commands = true, -- make /slash commands from MCP server prompts
      },
    },
  },
  keys = {
    {
      "<leader>m",
      mode = { "n", "v" },
      "<cmd>MCPHub<CR>",
      desc = "Open the MCPHub",
    },
  },
}

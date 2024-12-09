return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<C-n>",
        "<cmd>Neotree toggle<CR>",
        desc = "Toggle Neotree",
      },
    },
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            ".git",
          },
        },
      },
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
    },
  },
}

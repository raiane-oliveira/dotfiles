-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local del = vim.keymap.del

-- Remove default keymaps
-- del({ "n", "i", "v" }, "<A-j>")
-- del({ "n", "i", "v" }, "<A-k>")

-- Copy all
map("n", "<C-c>", "<cmd> %y+ <CR>", {})
map("n", "Y", "y$", { desc = "Yank to end of line" })

-- Better window movement location
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

map("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
map("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
map("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
map("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer" })

map("n", "<Tab>", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "<S-Tab>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })

-- Remove os keymaps padrão do LazyVim pra Ctrl+h/j/k/l abrirem espaço
-- pro vim-herdr-navigation
del("n", "<C-h>")
del("n", "<C-j>")
del("n", "<C-k>")
del("n", "<C-l>")

dofile(vim.fn.expand("~/src/vim-herdr-navigation/editor/nvim.lua"))

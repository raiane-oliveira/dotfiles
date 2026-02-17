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

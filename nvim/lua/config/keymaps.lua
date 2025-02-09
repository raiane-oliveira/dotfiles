-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.del("i", "<A-j>")
vim.keymap.del("i", "<A-k>")

local map = vim.keymap.set

map("i", "C-l", "<Right>", {})
map("i", "C-j", "<Bottom>", {})
map("i", "C-k", "<Top>", {})
map("i", "C-h", "<Left>", {})

map("i", "C-b", "<ESC>^i", {})
map("i", "C-e", "<End>", {})

map("n", "<C-c>", "<cmd> %y+ <CR>", {})

local transformWordsToCameCase = [[s/[-_]\([a-z]\)/\U\1/g]]
-- Custom snippets
map(
  "n",
  ",rc",
  '<cmd> -1read $HOME/Programming/snippets/react-component.tsx<CR>4V=fC:let @+ = expand("%:t")<CR>viwpldF.b~:'
    .. transformWordsToCameCase
    .. "<CR>",
  {
    noremap = true,
  }
)

map("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
map("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
map("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
map("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

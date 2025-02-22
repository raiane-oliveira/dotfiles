-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.wrap = true
vim.g.lazyvim_prettier_needs_config = false

vim.g.snacks_animate = false

opt.spelllang = { "en", "pt" }
opt.cursorline = false

opt.listchars = { tab = "  ", trail = " ", nbsp = "␣" }

opt.guicursor = "n-v-c-i:block"

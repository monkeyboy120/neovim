vim.g.mapleader = " "
vim.keymap.set('i', 'jk', '<Esc>')

vim.wo.relativenumber = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	{ "rose-pine/neovim", name = "rose-pine" },
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.5',
		-- or                              , branch = '0.1.x',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
	},
	{
		'nvim-treesitter/nvim-treesitter', build = 'TSUpdate'
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {}
	},
	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		opts = {}
	},
	{
		'rcarriga/nvim-notify'
	},
	{
		'stevearc/oil.nvim',
		opts = {},
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
}
local opts = {}

require("lazy").setup(plugins, opts)

local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

require("rose-pine").setup()
vim.cmd.colorscheme "rose-pine"

require("mason").setup()
require("mason-lspconfig").setup()

local config = require('nvim-treesitter.configs')
config.setup({
	ensure_installed = {'lua', 'vim', 'c', 'vimdoc', 'query'},
	autu_install = true,
	sync_install = false,
	highlight = { enable = true },
	indent = { enable = true },
})

require("oil").setup()
vim.keymap.set('n', '<leader>e', function()
	require("oil").open()
end)

local wk = require("which-key")
wk.register(mappings, opts)

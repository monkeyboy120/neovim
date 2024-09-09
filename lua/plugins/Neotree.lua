return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	config = function()
		vim.keymap.set("n", "<leader>e", ":Neotree filesystem reveal right<CR>")

		require("neo-tree").setup({
			event_handlers = {
				{
					event = "file_open_requested",
					handler = function()
						-- Auto close Neo-tree when a file is opened
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},
		})
	end,
}

return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup()
---@diagnostic disable-next-line: lowercase-global
		options = {
			theme = "dracula",
		}
	end,
}

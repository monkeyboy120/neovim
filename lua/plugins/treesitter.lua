return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local sysname = vim.uv.os_uname().sysname
			local install_dir

			if sysname == "Darwin" then
				install_dir = vim.fn.expand("~/Library/Application Support/nvim/site")
			else
				install_dir = vim.fn.expand("~/.local/share/nvim/site")
			end

			require("nvim-treesitter").setup({
				install_dir = install_dir,
			})

			local treesitter_group = vim.api.nvim_create_augroup("treesitter-setup", { clear = true })

			vim.api.nvim_create_autocmd("FileType", {
				group = treesitter_group,
				callback = function(args)
					local ok = pcall(vim.treesitter.start, args.buf)
					if ok then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
}

return {
	{
		"mason-org/mason.nvim",
		lazy = false,
		opts = {},
	},

	{
		"mason-org/mason-lspconfig.nvim",
		lazy = false,
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {
				"lua_ls",
				"clangd",
			},
			automatic_enable = true,
		},
	},

	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, cmp = pcall(require, "cmp_nvim_lsp")
			if ok then
				capabilities = cmp.default_capabilities(capabilities)
			end

			local servers = {
				lua_ls = {},
				clangd = {},
			}

			for name, cfg in pairs(servers) do
				cfg.capabilities = capabilities
				vim.lsp.config(name, cfg)
			end

			vim.lsp.enable(vim.tbl_keys(servers))

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local opts = { buffer = args.buf }
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>S", ":ClangdSwitchSourceHeader<CR>", opts)
				end,
			})
		end,
	},
}

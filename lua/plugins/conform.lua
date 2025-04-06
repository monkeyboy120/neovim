return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local function get_formatters()
				local formatters_by_ft = {
					lua = {},
					javascript = {},
					typescript = {},
					python = {},
					c = {},
					cpp = {},
					rust = {},
					zig = {},
				}
				local has_mason, mason_registry = pcall(require, "mason-registry")
				if has_mason then
					if mason_registry.is_installed("stylua") then
						table.insert(formatters_by_ft.lua, "stylua")
					end
					if mason_registry.is_installed("prettier") then
						table.insert(formatters_by_ft.javascript, "prettier")
						table.insert(formatters_by_ft.typescript, "prettier")
					end
					if mason_registry.is_installed("black") then
						table.insert(formatters_by_ft.python, "black")
					end
					if mason_registry.is_installed("clang-format") then
						table.insert(formatters_by_ft.c, "clang-format")
						table.insert(formatters_by_ft.cpp, "clang-format")
					end
					if mason_registry.is_installed("rustfmt") then
						table.insert(formatters_by_ft.rust, "rustfmt")
					end
					if mason_registry.is_installed("zigfmt") then
						table.insert(formatters_by_ft.zig, "zigfmt")
					end
				else
					-- Fallback configuration if Mason isn't installed
					formatters_by_ft.lua = { "stylua" }
					formatters_by_ft.c = { "clang-format" }
					formatters_by_ft.cpp = { "clang-format" }
					formatters_by_ft.rust = { "rustfmt" }
					formatters_by_ft.zig = { "zigfmt" }
				end
				return formatters_by_ft
			end

			require("conform").setup({
				formatters_by_ft = get_formatters(),
				format_on_save = {
					lsp_fallback = true,
					timeout_ms = 1000,
				},
			})

			vim.keymap.set("n", "<leader>gf", function()
				require("conform").format({ async = true })
			end, { desc = "Format file", noremap = true, silent = true })
		end,
	},
}

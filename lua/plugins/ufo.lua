-- ufo.lua
return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async",
	},
	event = "BufReadPost",
	opts = {
		close_fold_kinds = { "imports", "comment" },
		open_fold_hl_timeout = 400,
		provider_selector = function(bufnr, filetype, buftype)
			return { "lsp", "indent" }
		end,
		-- Custom virtual text handler for folds
		fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
			local newVirtText = {}
			local foldSize = endLnum - lnum
			-- You can change the suffix to your preferred symbol or text
			local suffix = ("  %d "):format(foldSize)
			local sufWidth = vim.fn.strdisplaywidth(suffix)
			local targetWidth = width - sufWidth
			local curWidth = 0
			for _, chunk in ipairs(virtText) do
				local chunkText = chunk[1]
				local chunkWidth = vim.fn.strdisplaywidth(chunkText)
				if targetWidth > curWidth + chunkWidth then
					table.insert(newVirtText, chunk)
				else
					local remaining = targetWidth - curWidth
					local truncatedText = truncate(chunkText, remaining)
					table.insert(newVirtText, { truncatedText, chunk[2] })
					break
				end
				curWidth = curWidth + chunkWidth
			end
			table.insert(newVirtText, { suffix, "MoreMsg" })
			return newVirtText
		end,
	},
	config = function(_, opts)
		require("ufo").setup(opts)

		-- Leader-based keymaps for folding
		vim.keymap.set("n", "<leader>fo", require("ufo").openAllFolds, { desc = "Open all folds" })
		vim.keymap.set("n", "<leader>fc", require("ufo").closeAllFolds, { desc = "Close all folds" })
		vim.keymap.set("n", "<leader>fe", require("ufo").openFoldsExceptKinds, { desc = "Open folds (except kinds)" })
		vim.keymap.set("n", "<leader>fx", require("ufo").closeFoldsWith, { desc = "Close folds (by kind)" })
		vim.keymap.set("n", "<leader>o", function()
			local lnum = vim.fn.foldclosed(".")
			if lnum ~= -1 then
				require("ufo").openFoldsExceptKinds(lnum)
			else
				-- Fallback: if no closed fold is detected, simply run the built-in command.
				vim.cmd("normal! zo")
			end
		end, { desc = "Open fold under cursor" })

		-- Optional: Set fold options for Neovim
		vim.o.foldcolumn = "1" -- Display fold column
		vim.o.foldlevel = 99 -- Large value so that ufo provider works correctly
		vim.o.foldlevelstart = 99 -- Start with all folds open
		vim.o.foldenable = true -- Enable folding
	end,
}

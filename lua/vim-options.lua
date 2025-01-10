vim.g.mapleader = " "

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("n", "<leader>e", ":Explore<CR>")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "number"

vim.api.nvim_set_option("clipboard", "unnamedplus")

-- Set tab width to 2 spaces for C++ files
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "cpp", "hpp" },
	command = "setlocal tabstop=2 shiftwidth=2 expandtab",
})

-- Disable Copilot globally by default
vim.g.copilot_enabled = false

-- Function to toggle Copilot manually
vim.api.nvim_create_user_command("EnableCopilot", function()
	vim.g.copilot_enabled = true
	vim.cmd("Copilot enable")
end, {})

vim.api.nvim_create_user_command("DisableCopilot", function()
	vim.g.copilot_enabled = false
	vim.cmd("Copilot disable")
end, {})

-- Ensure Copilot is disabled for all buffers by default
vim.cmd("autocmd BufNewFile,BufRead * Copilot disable")

vim.cmd("autocmd BufEnter * set formatoptions-=cro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")

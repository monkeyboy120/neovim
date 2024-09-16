vim.keymap.set("i", "jk", "<Esc>")
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "number"

vim.api.nvim_set_option("clipboard", "unnamedplus")

-- Set tab width to 2 spaces for C++ files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "cpp", "hpp" },
    command = "setlocal tabstop=2 shiftwidth=2 expandtab"
})

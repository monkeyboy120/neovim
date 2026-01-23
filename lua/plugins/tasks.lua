return {
	"Shatur/neovim-tasks",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"mfussenegger/nvim-dap", -- optional: for cmake debug
	},
	config = function()
		local Path = require("plenary.path")

		require("tasks").setup({
			default_params = {
				cmake = {
					cmd = "cmake",
					build_dir = tostring(Path:new("{cwd}", "build", "{build_type}")),
					build_type = "Debug",
					dap_name = "codelldb", -- change if your adapter has a different name
				},
			},
			save_before_run = true,
			params_file = "neovim.json",
			quickfix = {
				pos = "botright",
				height = 12,
				only_on_error = false,
			},
			dap_open_command = function()
				return require("dap").repl.open()
			end,
		})

		--------------------------------------------------------------------
		-- Keymap helper: keeps things simple and avoids rhs/table mixups --
		--------------------------------------------------------------------
		local function nmap(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
		end

		-- CMake-only keymaps

		-- Configure (generate build directory)
		nmap("<leader>cc", "<cmd>Task start cmake configure<CR>", "CMake: configure")

		-- Reconfigure
		nmap("<leader>cC", "<cmd>Task start cmake reconfigure<CR>", "CMake: reconfigure")

		-- Choose CMake target
		nmap("<leader>ct", "<cmd>Task set_module_param cmake target<CR>", "CMake: select target")

		-- Build selected target
		nmap("<leader>cB", "<cmd>Task start cmake build<CR>", "CMake: build target")

		-- Run selected target
		nmap("<leader>cr", "<cmd>Task start cmake run<CR>", "CMake: run target")

		-- Debug selected target (via nvim-dap)
		nmap("<leader>cd", "<cmd>Task start cmake debug<CR>", "CMake: debug target")

		-- Run ctest
		nmap("<leader>cT", "<cmd>Task start cmake ctest<CR>", "CMake: run ctest")

		-- Cancel current task
		nmap("<leader>cx", "<cmd>Task cancel<CR>", "CMake: cancel task")
	end,
}

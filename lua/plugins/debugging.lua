return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
		"jay-babu/mason-nvim-dap.nvim",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("dapui").setup()
		require("nvim-dap-virtual-text").setup({
			enabled = true,
			enable_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = true,
			show_stop_reason = true,
			commented = false,
			virt_text_pos = "eol",
		})
		require("mason-nvim-dap").setup({
			ensure_installed = { "codelldb" },
		})

		dap.adapters.lldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = vim.fn.stdpath("data") .. "/mason/bin/codelldb", -- Correct path
				args = { "--port", "${port}" },
			},
		}

		dap.configurations.cpp = {
			{
				name = "Launch file",
				type = "lldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = function()
					-- Ask the user for arguments
					local input = vim.fn.input("Program arguments: ")
					-- Split the input string into a table of arguments
					return vim.split(input, " ")
				end,
			},
		}

		dap.configurations.c = dap.configurations.cpp

		dap.configurations.rust = dap.configurations.cpp

		-- DAP UI listeners to open/close automatically
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- Keybindings for debugging
		vim.keymap.set("n", "<Leader>dt", ":DapToggleBreakpoint<CR>")

		vim.keymap.set("n", "<Leader>dc", ":DapContinue<CR>")
		vim.keymap.set("n", "<Leader>dx", ":DapTerminate<CR>")
		vim.keymap.set("n", "<Leader>do", ":DapStepOver<CR>")
		vim.keymap.set("n", "<Leader>di", ":DapStepInto<CR>")
		vim.keymap.set("n", "<Leader>ds", ":DapStepOut<CR>")
		vim.keymap.set("n", "<Leader>dr", ":DapRestart<CR>")
	end,
}

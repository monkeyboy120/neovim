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
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

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
				name = "Launch an executable",
				type = "lldb",
				request = "launch",
				cwd = "${workspaceFolder}",
				program = function()
					return coroutine.create(function(coro)
						local opts = {}
						pickers
						    .new(opts, {
							    prompt_title = "Path to executable",
							    finder = finders.new_oneshot_job(
							    { "find", ".", "-type", "f", "-perm", "+111" }, {}),
							    sorter = conf.generic_sorter(opts),
							    attach_mappings = function(buffer_number)
								    actions.select_default:replace(function()
									    actions.close(buffer_number)
									    coroutine.resume(coro,
										    action_state.get_selected_entry()[1])
								    end)
								    return true
							    end,
						    })
						    :find()
					end)
				end,
			},
		}

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

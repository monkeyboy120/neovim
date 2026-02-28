return {
	"mfussenegger/nvim-dap",
	lazy = false,
	dependencies = {
		{ "rcarriga/nvim-dap-ui", lazy = false },
		{ "nvim-neotest/nvim-nio", lazy = false },
		{ "theHamsta/nvim-dap-virtual-text", lazy = false },
		{ "jay-babu/mason-nvim-dap.nvim", lazy = false },
		{ "williamboman/mason.nvim", lazy = false },
	},
	config = function()
		local dap = require("dap")
		require("nio")
		local dapui = require("dapui")

		-- Helpful while setting up; you can change to "INFO" later
		dap.set_log_level("INFO")

		dapui.setup()
		require("nvim-dap-virtual-text").setup({
			enabled = true,
			commented = false,
			virt_text_pos = "eol",
		})

		require("mason-nvim-dap").setup({
			ensure_installed = { "codelldb" },
			automatic_setup = true,
		})

		-- === Adapter: codelldb (Mason) ===
		dap.adapters.lldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
				args = { "--port", "${port}" },
			},
		}

		-- Small helper: choose executable (defaults to ./<cwd>/)
		local function pick_executable()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end

		-- Small helper: parse args robustly (handles multiple spaces)
		local function input_args()
			local input = vim.fn.input("Program arguments: ")
			if input == nil or input == "" then
				return {}
			end
			return vim.fn.split(input, " ", true)
		end

		-- Optional helper: build current project quickly (clang++ on macOS)
		local function build_cpp()
			-- Customize these to match your project
			local cmd = "clang++ -g -O0 -fno-omit-frame-pointer -std=c++17 *.cpp -o a.out"
			vim.notify("Building: " .. cmd)
			vim.fn.system(cmd)
			if vim.v.shell_error ~= 0 then
				vim.notify("Build failed:\n" .. vim.fn.system(cmd), vim.log.levels.ERROR)
			else
				vim.notify("Build OK", vim.log.levels.INFO)
			end
		end

		-- === Configurations ===
		dap.configurations.cpp = {
			{
				name = "Launch (codelldb)",
				type = "lldb",
				request = "launch",
				program = pick_executable,
				cwd = vim.fn.getcwd(),
				args = input_args,
				stopOnEntry = false,

				-- macOS quality-of-life: don't stop in dyld/shared-lib events
				initCommands = {
					"settings set target.process.stop-on-sharedlibrary-events 0",
				},

				-- If you ever want a console window (rarely needed), set to true
				-- runInTerminal = false,
			},
			{
				name = "Build & Launch (a.out)",
				type = "lldb",
				request = "launch",
				preLaunchTask = function()
					build_cpp()
				end,
				program = function()
					return vim.fn.getcwd() .. "/a.out"
				end,
				cwd = vim.fn.getcwd(),
				args = input_args,
				stopOnEntry = false,
				initCommands = {
					"settings set target.process.stop-on-sharedlibrary-events 0",
				},
			},
		}

		dap.configurations.c = dap.configurations.cpp
		dap.configurations.rust = dap.configurations.cpp

		-- === UI behavior ===
		-- Open UI when debugging starts
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end

		-- Don’t auto-close immediately; it’s annoying while you’re iterating.
		-- Provide a manual close key instead.
		-- (If you prefer auto-close, uncomment these.)
		-- dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
		-- dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

		-- === Keymaps ===
		local map = vim.keymap.set
		map("n", "<Leader>dt", dap.toggle_breakpoint)
		map("n", "<Leader>dT", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end)

		map("n", "<Leader>dc", dap.continue)
		map("n", "<Leader>dx", dap.terminate)

		map("n", "<Leader>do", dap.step_over)
		map("n", "<Leader>di", dap.step_into)
		map("n", "<Leader>ds", dap.step_out)

		map("n", "<Leader>du", dapui.toggle)
		map("n", "<Leader>dr", dap.run_last)
		map("n", "<Leader>de", function()
			dap.repl.open()
		end)

		-- Useful: see log quickly
		map("n", "<Leader>dl", function()
			vim.cmd("DapShowLog")
		end)
	end,
}

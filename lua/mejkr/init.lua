local commands = require("mejkr.commands")
local config = require("mejkr.config")

local M = {}

local command_definitions = {
	edit_commands = {
		name = "MejkrEdit",
		desc = "Create or edit current commands",
	},
	save_commands = {
		name = "MejkrSave",
		desc = "Save current commands for this project",
	},
	execute_commands = {
		name = "MejkrExecute",
		desc = "Execute the current commands",
	},
	run_file = {
		name = "MejkrRunFile",
		desc = "Run current file",
	},
	toggle_output_buffer = {
		name = "MejkrToggleOutput",
		desc = "Toggle mejkr output window",
	},
	manage_saved_commands = {
		name = "MejkrManageSavedCommands",
		desc = "Manage the files in which commands are saved",
	},
}

function M.setup(user_config)
	config.setup(user_config)

	for func_name, def in pairs(command_definitions) do
		local func = commands[func_name]

		M[func_name] = func
	end

	M.restart_execution = commands.restart_execution
	M.move_window = commands.move_window
	vim.api.nvim_create_user_command(
		"MejkrMoveWindow",
		commands.move_window,
		{ desc = "Change how the window is created for this session.", nargs = 1 }
	)
end

return M

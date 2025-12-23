local commands = require("mejkr.commands")
local config = require("mejkr.config")

local M = {}

local command_definitions = {
	edit_commands = {
		name = "MejkrEdit",
		desc = "Create or edit current commands",
		config_key = "edit_commands",
		keymap_desc = "Mejkr edit commands",
	},
	save_commands = {
		name = "MejkrSave",
		desc = "Save current commands for this project",
		config_key = "save_commands",
		keymap_desc = "Mejkr save commands",
	},
	run = {
		name = "MejkrRun",
		desc = "Run current commands",
		config_key = "run_commands",
		keymap_desc = "Mejkr execute commands",
	},
	run_file = {
		name = "MejkrRunFile",
		desc = "Run current file",
		config_key = "run_file",
		keymap_desc = "Mejkr run current file",
	},
	toggle_output_buffer = {
		name = "MejkrToggleOutput",
		desc = "Toggle mejkr output window",
		config_key = "toggle_output",
		keymap_desc = "Mejkr toggle output buffer",
	},
	manage_saved_commands = {
		name = "MejkrManageSavedCommands",
		desc = "Manage the files in which commands are saved",
		config_key = "manage_saved_commands",
		keymap_desc = "Mejkr manage saved commands",
	},
}

function M.setup(user_config)
	config.setup(user_config)

	for func_name, def in pairs(command_definitions) do
		local func = commands[func_name]

		vim.api.nvim_create_user_command(def.name, func, { desc = def.desc })

		local keymap = config.config.keymaps[def.config_key]
		if keymap then
			vim.keymap.set("n", keymap, func, { desc = def.keymap_desc })
		end

		M[func_name] = func
	end
end

return M

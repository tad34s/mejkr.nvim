local commands = require("mejkr.commands")
local config = require("mejkr.config")

local M = {}

local command_definitions = {
	edit_commands = {
		desc = "Create or edit current commands",
		fn = commands.edit_commands,
	},
	save_commands = {
		desc = "Save current commands for this project",
		fn = commands.save_commands,
	},
	execute = {
		desc = "Execute the current commands",
		fn = commands.execute,
	},
	run_file = {
		desc = "Run current file",
		fn = commands.run_file,
	},
	toggle_output_buffer = {
		desc = "Toggle mejkr output window",
		fn = commands.toggle_output_buffer,
	},
	manage_saved_commands = {
		desc = "Manage the files in which commands are saved",
		fn = commands.manage_saved_commands,
	},
}

local extra_exported_functions = {
	"get_commands",
	"execute_commands",
	"stop_execution",
	"restart_execution",
	"change_window",
}

function M.setup(user_config)
	config.setup(user_config)

	vim.api.nvim_create_user_command("Mejkr", function(opts)
		local subcmd = opts.fargs[1]

		if not subcmd or not command_definitions[subcmd] then
			local valid = table.concat(vim.tbl_keys(command_definitions), ", ")
			vim.notify("Unknown subcommand: " .. (subcmd or "") .. "\nValid: " .. valid, vim.log.levels.ERROR)
			return
		end

		command_definitions[subcmd].fn()
	end, {
		nargs = "+",
		desc = "Mejkr commands",
		complete = function(arglead)
			return vim.tbl_filter(function(key)
				return key:find(arglead, 1, true) == 1
			end, vim.tbl_keys(command_definitions))
		end,
	})

	-- export commands also as functions
	for func_name, def in pairs(command_definitions) do
		M[func_name] = def.fn
	end

	-- export additional useful functions
	for _, name in ipairs(extra_exported_functions) do
		M[name] = commands[name]
	end
end

return M

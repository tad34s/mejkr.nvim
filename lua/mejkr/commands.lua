local M = {}
local mejkr_io = require("mejkr.io")
local state = require("mejkr.state").state
local ui = require("mejkr.ui")
local execution = require("mejkr.execute")
local config = require("mejkr.config")

function M.save_commands()
	if state.stored_commands then
		mejkr_io.save_commands(state.stored_commands)
	else
		vim.notify("Cannot save the commands, none currently stored.", vim.log.levels.WARN)
	end
end

function M.edit_commands()
	if not state.edit_buf then
		state.edit_buf = ui.create_edit_buf(state)
	end

	ui.open_buf(state.edit_buf, state:get_window(), true)
	vim.cmd("startinsert")
end

function M.execute_commands()
	if state.stored_commands then
		vim.notify("Executing commands...", vim.log.levels.INFO)
		execution.execute_commands(state, state.stored_commands)
		state.last_ran_commands = state.stored_commands
	elseif state.last_ran_commands then
		vim.notify("Executing last commands...", vim.log.levels.INFO)
		execution.execute_commands(state, state.last_ran_commands)
		state.last_ran_commands = state.last_ran_commands
	else
		vim.notify("No commands stored. Use :MejkrEdit to add some.", vim.log.levels.WARN)
	end
end

function M.restart_execution()
	if execution.has_terminal_job_running(state) then
		state.pending_restart = true
		vim.fn.jobstop(state.job_id)
		return
	end
	M.execute_commands()
end

function M.run_file()
	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname == "" then
		vim.notify("No file is currently open.", vim.log.levels.WARN)
		return
	end

	local filepath = vim.fn.fnamemodify(bufname, ":p")
	local ext = vim.fn.fnamemodify(bufname, ":e")

	if ext == "" then
		vim.notify("Current file has no extension.", vim.log.levels.WARN)
		return
	end

	local to_run = config.config.run_configs[ext]
	if type(to_run) ~= "function" then
		vim.notify(string.format("No run config for extension: .%s", ext), vim.log.levels.WARN)
		return
	end

	local commands = to_run(filepath)
	execution.execute_commands(state, commands)

	state.last_ran_commands = commands
end

function M.toggle_output_buffer()
	ui.toggle_output_buffer(state)
end

function M.move_window(cmd)
	if type(cmd) == "table" then
		cmd = cmd.args
	end
	state._create_window_command = cmd
	ui.redraw_window(state)
end

function M.manage_saved_commands()
	local dir = mejkr_io.data_path()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)

	-- Calculate the position to center the window
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- Create a new buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Set up window configuration
	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	-- Create the floating window
	local win = vim.api.nvim_open_win(buf, true, win_config)

	vim.cmd("Explore " .. vim.fn.fnameescape(dir)) -- Open netrw in that directory
end

return M

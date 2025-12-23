local M = {}
local mejkr_io = require("mejkr.io")
local state = require("mejkr.state").state
local ui = require("mejkr.ui")
local execute = require("mejkr.execute")
local config = require("mejkr.config")

function M.save_commands()
	mejkr_io.save_commands(state.stored_commands)
end

function M.edit_commands()
	ui.hide_window(state.output.win)

	local edit_state = state.edit
	if not edit_state.buf then
		edit_state.buf = ui.create_edit_buf(state)
	end

	edit_state.win = ui.go_to_buf(edit_state.buf, edit_state.win)
	state.edit = edit_state
	vim.cmd("startinsert")
end

function M.run()
	if state.stored_commands then
		vim.notify("Executing commands...", vim.log.levels.INFO)
		execute.execute_commands(state, state.stored_commands)
		state.last_ran_commands = state.stored_commands
	elseif state.last_ran_commands then
		vim.notify("Executing last commands...", vim.log.levels.INFO)
		execute.execute_commands(state, state.last_ran_commands)
		state.last_ran_commands = state.last_ran_commands
	else
		vim.notify("No commands stored. Use :MejkrEdit to add some.", vim.log.levels.WARN)
	end
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
	execute.execute_commands(state, commands)

	state.last_ran_commands = commands
end

function M.toggle_output_buffer()
	ui.toggle_output_buffer(state)
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

	-- Open the file explorer in the specified directory
	vim.cmd("lcd " .. vim.fn.fnameescape(dir)) -- Change local directory
	vim.cmd("edit " .. vim.fn.fnameescape(dir)) -- Open netrw in that directory
end

return M

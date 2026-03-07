local M = {}
local config = require("mejkr.config")

function M.create_window(new_window_command)
	if new_window_command == nil then
		local height = config.config.default_height
		vim.cmd(string.format("botright %dsplit", height))
	elseif type(new_window_command) == "function" then
		new_window_command()
	elseif type(new_window_command) == "string" then
		vim.cmd(new_window_command)
	end

	local win = vim.api.nvim_get_current_win()
	vim.wo[win].winfixwidth = true
	vim.wo[win].winfixbuf = true
	return win
end

function M.create_edit_buf(state)
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(buf, "Mejkr Commands")

	vim.bo[buf].buftype = "acwrite"
	vim.bo[buf].filetype = "sh"
	vim.bo[buf].swapfile = false
	vim.bo[buf].bufhidden = "hide"

	if state.stored_commands then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, state.stored_commands)
	end
	vim.bo[buf].modified = false

	if config.config.enable_fish_completion then
		local completion = require("mejkr.completion")
		vim.bo[buf].omnifunc = completion.fish_omnifunc
		vim.keymap.set("i", "<Tab>", "<C-x><C-o>", { buffer = buf, noremap = true, silent = true })
	end

	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			state.stored_commands = lines
			vim.bo[buf].modified = false
			vim.notify("Commands saved for this session!", vim.log.levels.INFO)
		end,
	})

	return buf
end

function M.create_output_buf()
	local buf = vim.api.nvim_create_buf(true, false)
	vim.bo[buf].bufhidden = "hide"
	vim.bo[buf].modifiable = false
	vim.bo[buf].swapfile = false
	vim.api.nvim_buf_set_name(buf, "Mejkr Output")
	return buf
end

function M.open_buf(buf, win, move_focus)
	if move_focus == nil then
		move_focus = true
	end

	if win and vim.api.nvim_win_is_valid(win) then
		if vim.api.nvim_win_get_buf(win) ~= buf then
			vim.wo[win].winfixbuf = false
			vim.api.nvim_win_set_buf(win, buf)
			vim.wo[win].winfixbuf = true
		end
	end

	if move_focus then
		vim.api.nvim_set_current_win(win)
	end
end

function M.toggle_output_buffer(state)
	if not state.output_buf or not vim.api.nvim_buf_is_valid(state.output_buf) then
		vim.notify("No output buffer.", vim.log.levels.WARN)
		state.output_buf = nil
		return
	end

	if state._window and vim.api.nvim_win_is_valid(state._window) then
		state:hide_window()
	else
		M.open_buf(state.output_buf, state:get_window())
	end
end

function M.redraw_window(state)
	print(state)
	if state._window and vim.api.nvim_win_is_valid(state._window) then
		local curr_buf = vim.api.nvim_win_get_buf(state._window)
		state:hide_window()
		M.open_buf(curr_buf, state:get_window())
	end
end
return M

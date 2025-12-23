local M = {}
local config = require("mejkr.config")

function M.create_window(buf, height)
	height = height or config.config.default_height
	vim.cmd(string.format("botright %dsplit", height))
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	return win
end

function M.create_edit_buf(state)
	local buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_name(buf, "Mejkr Commands")

	vim.bo[buf].buftype = "acwrite"
	vim.bo[buf].filetype = "sh"
	vim.bo[buf].swapfile = false
	vim.bo[buf].bufhidden = "hide"

	if state.stored_commands then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, state.stored_commands)
	end

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
			vim.bo[state.edit.buf].modified = false
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

function M.go_to_buf(buf, win)
	if buf and vim.api.nvim_buf_is_valid(buf) then
		if win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_set_current_win(win)
		else
			win = M.create_window(buf)
			vim.api.nvim_set_current_buf(buf)
		end
		return win
	end
end

function M.hide_window(win)
	if not win or not vim.api.nvim_win_is_valid(win) then
		return
	end

	local is_visible = false
	for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if w == win then
			is_visible = true
			break
		end
	end

	if is_visible then
		vim.api.nvim_win_hide(win)
	end
end

function M.toggle_output_buffer(state)
	if not state.output.buf or not vim.api.nvim_buf_is_valid(state.output.buf) then
		vim.notify("No output buffer.", vim.log.levels.WARN)
		state.output.buf = nil
		return
	end

	if state.output.win and vim.api.nvim_win_is_valid(state.output.win) then
		M.hide_window(state.output.win)
		state.output.win = nil
	else
		state.output.win = M.go_to_buf(state.output.buf, state.output.win)
	end
end

return M

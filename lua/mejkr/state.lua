local M = {}

local mejkr_io = require("mejkr.io")
local ui = require("mejkr.ui")
local config = require("mejkr.config")

M.state = {
	stored_commands = mejkr_io.read_saved_commands(),
	last_ran_commands = nil,
	_window = nil,
	edit_buf = nil,
	output_buf = nil,
	_create_window_command = config.config.create_window_command,
	job_id = nil,
}

function M.state:create_window_cmd()
	-- if self._create_window_command == nil then
	-- 	self._create_window_command = config.config.create_window_command
	-- end

	return self._create_window_command
end

function M.state:get_window()
	if self._window == nil or not vim.api.nvim_win_is_valid(self._window) then
		self._window = ui.create_window(self:create_window_cmd())
	end

	return self._window
end

function M.state:hide_window()
	local win = self._window
	if not win or not vim.api.nvim_win_is_valid(win) then
		return
	end

	vim.api.nvim_win_hide(win)

	self._window = nil
end

return M

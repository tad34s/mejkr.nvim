local M = {}
local ui = require("mejkr.ui")

local function has_terminal_job_running(buf)
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return false
	end

	if vim.api.nvim_buf_get_option(buf, "buftype") ~= "terminal" then
		return false
	end

	local chan = vim.api.nvim_buf_get_option(buf, "channel")
	if not chan or chan == 0 then
		return false
	end

	local result = vim.fn.jobwait({ chan }, 0)
	return result[1] == -1
end

function M.execute_commands(state, commands_table)
	ui.hide_window(state.edit.win)
	ui.hide_window(state.output.win)

	if has_terminal_job_running(state.output.buf) then
		vim.notify("A terminal is already running in the output buffer.", vim.log.levels.WARN)
		state.output.win = ui.go_to_buf(state.output.buf, state.output.win)
		return
	end

	local script = table.concat(commands_table, "\n")
	local output_buf = ui.create_output_buf()
	local output_state = { buf = output_buf, win = nil }
	state.output = output_state

	output_state.win = ui.go_to_buf(output_state.buf, output_state.win)

	local chan = vim.fn.termopen({ "sh", "-c", script }, {
		on_exit = function(_, code, _)
			if code == 0 then
				vim.notify("Commands finished successfully.", vim.log.levels.INFO)
			else
				vim.notify(("Commands exited with code %d."):format(code), vim.log.levels.ERROR)
			end
		end,
	})

	if chan <= 0 then
		vim.notify("Failed to start terminal for commands.", vim.log.levels.ERROR)
		return
	end
end

return M

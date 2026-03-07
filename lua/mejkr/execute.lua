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
	if has_terminal_job_running(state.output_buf) then
		vim.notify("Something is already running in the output buffer.", vim.log.levels.WARN)

		ui.open_buf(state.output_buf, state:get_window(), false)
		return
	end

	local script = table.concat(commands_table, "\n")
	if state.output_buf == nil or not vim.api.nvim_buf_is_valid(state.output_buf) then
		state.output_buf = ui.create_output_buf()
	end
	vim.bo[state.output_buf].modified = false

	ui.open_buf(state.output_buf, state:get_window(), false)
	vim.api.nvim_buf_call(state.output_buf, function()
		vim.fn.jobstart({ "sh", "-c", script }, {
			term = true,
			on_exit = function(_, code, _)
				if code == 0 then
					vim.notify("Commands finished successfully.", vim.log.levels.INFO)
				else
					vim.notify(("Commands exited with code %d."):format(code), vim.log.levels.ERROR)
				end
			end,
		})
	end)
	vim.api.nvim_buf_set_name(state.output_buf, "Mejkr Output")
end

return M

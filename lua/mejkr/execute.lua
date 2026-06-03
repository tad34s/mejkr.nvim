local M = {}
local ui = require("mejkr.ui")

function M.has_terminal_job_running(state)
	return state.job_id ~= nil and state.job_id > 0
end

function M.execute_commands(state, commands_table)
	if M.has_terminal_job_running(state) then
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
	state.job_id = vim.api.nvim_buf_call(state.output_buf, function()
		return vim.fn.jobstart({ "sh", "-c", script }, {
			term = true,
			on_exit = function(_, code, _)
				local commands = require("mejkr.commands")
				state.job_id = nil
				if state.pending_restart then
					state.pending_restart = false
					commands.execute()
					return
				end
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

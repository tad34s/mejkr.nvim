local plugin_name = "mejkr"

local M = {}

function M.data_path()
	local data_path = vim.fn.stdpath("data")
	return data_path .. "/" .. plugin_name
end

function M.project_data_file()
	local filename = vim.fn.getcwd(0, 0)
	filename = filename:gsub('[\\/:*?"<>|]', "_")
	filename = filename:gsub("^%s+", ""):gsub("%s+$", "")
	local filepath = M.data_path() .. "/" .. filename .. ".sh"
	return filepath
end

--- Read commands save if non are saved return nil
function M.read_saved_commands()
	local filepath = M.project_data_file()

	local file = io.open(filepath, "r")
	if not file then
		return nil
	end

	local lines = {}
	for line in file:lines() do
		table.insert(lines, line)
	end

	file:close()
	return lines
end

function M.save_commands(stored_commands)
	local filepath = M.project_data_file()

	vim.fn.mkdir(M.data_path(), "p")

	local _ = vim.fn.writefile(stored_commands, filepath)

	vim.notify("Written to: " .. filepath, vim.log.levels.INFO)
end

function M.make_save_callback(state, config)
	local function save(lines)
		local path = M.project_data_file()
		vim.fn.mkdir(M.data_path(), "p")
		vim.fn.writefile(lines, path)
	end

	local save_behaviors = {
		off = function(_) end,
		already_saved = function(lines)
			if vim.fn.filereadable(M.project_data_file()) == 1 then
				save(lines)
			end
		end,
		all = save,
	}
	local save_behavior = save_behaviors[config.autosave] or save_behaviors.off
	return function(ev)
		local buf = ev.buf
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		state.stored_commands = lines
		vim.bo[buf].modified = false
		vim.notify("Commands saved for this session!", vim.log.levels.INFO)
		save_behavior(lines)
	end
end

return M

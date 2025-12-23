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

	local result = vim.fn.writefile(stored_commands, filepath)

	vim.notify("Written to: " .. filepath, vim.log.levels.INFO)
end

return M

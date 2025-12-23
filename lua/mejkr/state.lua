local M = {}

local mejkr_io = require("mejkr.io")

M.state = {
	stored_commands = mejkr_io.read_saved_commands(),
	last_ran_commands = nil,
	edit = {
		buf = nil,
		win = nil,
	},
	output = {
		buf = nil,
		win = nil,
	},
}

return M

local M = {}

local default_run_configs = {
	py = function(fp)
		return { "python " .. vim.fn.shellescape(fp) }
	end,

	cpp = function(fp)
		local dir = vim.fn.fnamemodify(fp, ":h")
		local filename_no_ext = vim.fn.fnamemodify(fp, ":t:r")
		local outpath = dir .. "/" .. filename_no_ext

		local compile_cmd = string.format("g++ -pedantic %s -o %s", vim.fn.shellescape(fp), vim.fn.shellescape(outpath))

		local run_cmd = vim.fn.shellescape(outpath)

		return { compile_cmd, run_cmd }
	end,

	tex = function(fp)
		return { "tectonic " .. fp }
	end,
}

local defaults = {
	run_configs = default_run_configs,
	plugin_name = "mejkr",
	enable_fish_completion = false,
	create_window_command = nil,
	default_height = 10,
}

M.config = vim.deepcopy(defaults)

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", defaults, user_config or {})

	if user_config and user_config.run_configs then
		M.config.run_configs = vim.tbl_extend("force", default_run_configs, user_config.run_configs)
	end
end

return M

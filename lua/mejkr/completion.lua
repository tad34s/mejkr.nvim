local M = {}

function M.fish_completion_handler(findstart, base)
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	if findstart == 1 then
		-- Find start of "word to complete": from cursor back as \k* or use \f* for files
		local start = vim.fn.match(line:sub(1, col), "\\f*$")
		-- Save as context the part BEFORE the word to be replaced
		M._completion_context = line:sub(1, start)
		return start
	else
		-- Construct full line as context for fish (all before + base)
		local full = (M._completion_context or "") .. base
		-- Call fish
		local handle = io.popen("fish -c 'complete -C \"" .. full:gsub("'", "'\\''") .. "\"'")
		local result = handle:read("*a")
		handle:close()

		local matches = {}
		local seen = {}
		for s in result:gmatch("[^\r\n]+") do
			local suggestion, description = s:match("^([^\t]*)\t?(.*)")
			if suggestion and suggestion ~= "" then
				-- Only insert the *new* portion not already present as base
				-- If suggestion starts with base, return suggestion, else skip
				-- OR, always return suggestion, so user gets full replacement
				if not seen[suggestion] then
					seen[suggestion] = true
					table.insert(matches, {
						word = suggestion,
						menu = description ~= "" and description or "[Fish]",
						icase = 1,
					})
				end
			end
		end
		return matches
	end
end

vim.mejkr_fish_completion = M.fish_completion_handler

M.fish_omnifunc = "v:lua.vim.mejkr_fish_completion"

return M

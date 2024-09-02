local M = {}

-- Function to read the query from the current buffer
local function get_query()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	return table.concat(lines, "\n")
end

-- Function to execute the query using psql
local function execute_query(query)
	local command = string.format("psql -c '%s'", query:gsub("'", "''"))
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result
end

-- Function to create and populate a popup window with results
local function show_results(results)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(results, "\n"))

	local width = math.min(120, vim.o.columns - 4)
	local height = math.min(30, vim.o.lines - 4)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_win_set_option(win, "wrap", false)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- Main function to run the query and show results
function M.run_query()
	local query = get_query()
	local results = execute_query(query)
	show_results(results)
end

-- Set up the plugin command
vim.api.nvim_create_user_command("PSQLRun", M.run_query, {})

return M

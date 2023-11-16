local M = {}

M.root_patterns = { ".git", "lua" }

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
function M.get_root()
	---@type string?
	local path = vim.api.nvim_buf_get_name(0)
	path = path ~= "" and vim.loop.fs_realpath(path) or nil
	---@type string[]
	local roots = {}
	if path then
		for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
			local workspace = client.config.workspace_folders
			local paths = workspace
					and vim.tbl_map(function(ws)
						return vim.uri_to_fname(ws.uri)
					end, workspace)
				or client.config.root_dir and { client.config.root_dir }
				or {}
			for _, p in ipairs(paths) do
				local r = vim.loop.fs_realpath(p)
				if path:find(r, 1, true) then
					roots[#roots + 1] = r
				end
			end
		end
	end
	table.sort(roots, function(a, b)
		return #a > #b
	end)
	---@type string?
	local root = roots[1]
	if not root then
		path = path and vim.fs.dirname(path) or vim.loop.cwd()
		---@type string?
		root = vim.fs.find(M.root_patterns, { path = path, upward = true })[1]
		root = root and vim.fs.dirname(root) or vim.loop.cwd()
	end
	---@cast root string
	return root
end

function M.is_not_root_pattern(path)
	return string.match(path, "^.")
		or string.match(path, "^~")
		or string.match(path, "^/")
		or string.match(path, "^[A-Za-z]:\\")
end

function M.telescope(fn_inst)
	local builtin = "find_files"
	local root = M.get_root()
	local opts = {
		cwd = root,
		find_command = { "rg", "-tverilog", "--color", "never", "--files" },
		attach_mappings = function(prompt_bufnr)
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				fn_inst(selection[1])
			end)
			return true
		end,
	}
	require("telescope.builtin")[builtin](opts)
end

return M

local Util = require("autoverilog.util")

local M = {}

function M.extract(cmd)
	local f = assert(io.open(cmd, "r"))
	local s = assert(f:read("*a"))

	-- Extract module head
	local head_pattern = "(module.-%);)"
	local head = s:match(head_pattern)
	assert(head, "Error: Module not found")

	-- Get module name
	local name_pattern = "module%s+([%w_]+)%s*"
	local module_name = head:match(name_pattern)

	-- Get parameters
	local params = {}
	local param_pattern = "parameter%s+[%l%s%[%]%d:]*([%u%d_]+%s*=%s*%d+)"
	local params_match = head:gmatch(param_pattern)
	if params_match then
		for param in params_match do
			local name, value = param:match("([%w_]+)%s*=%s*(%w+)")
			table.insert(params, { name, value })
		end
	end

	-- Get Port
	local ports = {}
	local port_pattern = "%b();"
	local ports_match = head:match(port_pattern)

	local port_modes = { "^o?[iu][nt][op]ut%s+%w+%s*%b[]%s*(.-)$", "^o?[iu][nt][op]ut%s+%w+%s*(.-)$" }
	for line in ports_match:gmatch("%s*([^\r\n();]+)") do
		for _, mode in ipairs(port_modes) do
			local port = line:match(mode)
			if port then
				for p in port:gmatch("[^,%s%[%]%u]+") do
					table.insert(ports, p)
				end
				break
			end
		end
	end

	return { module_name, params, ports }
end

function M.geninst(module_name, params, ports)
	local inst_code = ""
	if #params > 0 then
		inst_code = inst_code .. module_name .. " #("
		for i, param in ipairs(params) do
			if i == #params then
				inst_code = inst_code .. string.format(".%s(%s)) u_%s(", param[1], param[2], module_name)
			else
				inst_code = inst_code .. string.format(".%s(%s),", param[1], param[2])
			end
		end
	else
		inst_code = inst_code .. string.format("%s u_%s(", module_name, module_name)
	end

	for i, port in ipairs(ports) do
		if i == #ports then
			inst_code = inst_code .. string.format(".%s\t(%s));", port, port)
		else
			inst_code = inst_code .. string.format(".%s\t(%s),", port, port)
		end
	end

	return inst_code
end

function M.autoinst()
	local builtin = "find_files"
	local root = Util.get_root()
	local opts = {
		cwd = root,
		find_command = { "rg", "-tverilog", "--color", "never", "--files" },
		attach_mappings = function(prompt_bufnr)
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				local module = M.extract(root .. "/" .. selection[1])
				local inst_code = M.geninst(module[1], module[2], module[3])
				vim.api.nvim_put({ inst_code }, "", false, true)
			end)
			return true
		end,
	}
	require("telescope.builtin")[builtin](opts)
end

return M

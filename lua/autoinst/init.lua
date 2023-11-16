vim.o.runtimepath = vim.o.runtimepath .. "," .. vim.fn.getcwd()
local Util = require("autoinst.util")

local function extract(path)
	local f = assert(io.open(path, "r"))
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

local function geninst(module_name, params, ports)
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

local function inst_with_path(path)
	local full_path = ""
	if Util.is_not_root_pattern(path) then
		full_path = path
	else
		local root = Util.get_root()
		full_path = root .. "/" .. path
	end
	local module = extract(full_path)
	local inst_code = geninst(module[1], module[2], module[3])
	vim.api.nvim_put({ inst_code }, "", false, true)
end

local function inst_with_telescope()
	Util.telescope(inst_with_path)
end

local function auto_instantiation(args)
	if args == "" then
		inst_with_telescope()
	else
		inst_with_path(args)
	end
end

local autoinst = {}
local function setup(opt)
	autoinst = vim.tbl_extend("force", {
		cmd = "AutoInst",
		map = "<leader>fv",
	}, opt or {})

	vim.keymap.set({ "n", "i" }, autoinst.map, inst_with_telescope, { desc = "Auto instantiation verilog module" })
	vim.api.nvim_create_user_command(autoinst.cmd, function(opts)
		auto_instantiation(opts.args)
	end, { nargs = "?" })
end

return {
	setup = setup,
}

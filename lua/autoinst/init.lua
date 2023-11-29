local Util = require("autoinst.util")
local TS = vim.treesitter

local function get_query(stext, query_string)
	local parser = TS.get_string_parser(stext, "verilog")
	local ok, query = pcall(vim.treesitter.query.parse, parser:lang(), query_string)

	if not ok then
		print("Failed to parse query")
		return
	end

	local tree = parser:parse()[1]

	local items = {}
	for id, node, metadata in query:iter_captures(tree:root(), 0, 0, -1) do
		local item = vim.treesitter.get_node_text(node, stext, metadata[id])
		table.insert(items, item)
	end

	return items
end

local function get_header_items(file_path)
	local stext = io.open(file_path):read("*a")
	local name = get_query(stext, "(module_header (simple_identifier) @module_name)")
	local params = {
		idents = get_query(stext, "(param_assignment (parameter_identifier) @param_name )"),
		consts = get_query(stext, "(param_assignment (constant_param_expression) @param_value)"),
	}

	local ports = get_query(stext, "(ansi_port_declaration (port_identifier) @port_name)")

	if not name or not params or not ports then
		vim.notify("Failed to get query")
		return
	end

	return {
		name = name[1],
		params = params,
		ports = ports,
	}
end

local function gen_inst(name, params, ports)
	local inst_code = ""
	if #params.idents > 0 then
		inst_code = inst_code .. name .. " #("
		for i, ident in ipairs(params.idents) do
			if i == #params.idents then
				inst_code = inst_code .. string.format(".%s(%s)) u_%s(", ident, params.consts[i], name)
			else
				inst_code = inst_code .. string.format(".%s(%s),", ident, params.consts[i])
			end
		end
	else
		inst_code = inst_code .. string.format("%s u_%s(", name, name)
	end

	for i, port in ipairs(ports) do
		if i == #ports then
			inst_code = inst_code .. string.format(".%s(%s));", port, port)
		else
			inst_code = inst_code .. string.format(".%s(%s),", port, port)
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

	local items = get_header_items(full_path)
	if items == nil then
		return
	end
	local inst_code = gen_inst(items.name, items.params, items.ports)
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
	local defaultOpts = { cmd = "AutoInst" }
	local userOpts = opt or {}
	for key, value in pairs(defaultOpts) do
		autoinst[key] = userOpts[key] ~= "" and userOpts[key] or value
	end

	vim.api.nvim_create_user_command(autoinst.cmd, function(opts)
		auto_instantiation(opts.args)
	end, { nargs = "?" })
end

return {
	setup = setup,
}

local Autoverilog = require("autoverilog")

vim.api.nvim_create_user_command("AutoInst", function()
	Autoverilog.autoinst()
end, {})

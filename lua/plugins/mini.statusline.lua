-- Statusline
-- https://github.com/echasnovski/mini.statusline
return {
	"echasnovski/mini.statusline",
	config = function()
		local statusline = require("mini.statusline")
		statusline.setup({
			use_icons = true
		})
	end,
}

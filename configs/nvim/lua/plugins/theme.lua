return {
	-- {
	-- 	"c3r5b8/adwaita.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	--
	-- 	config = function()
	-- 		-- vim.g.adwaita_darker = true -- for darker version
	-- 		-- vim.g.adwaita_disable_cursorline = true -- to disable cursorline
	-- 		vim.g.adwaita_transparent = true -- makes the background transparent
	-- 		vim.cmd("colorscheme adwaita")
	-- 	end,
	-- },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("catppuccin").setup({
				flavour = "latte",
				background = {
					light = "latte",
					dark = "mocha",
				},
			})

			vim.cmd.colorscheme("catppuccin-latte")
		end,
	},
}

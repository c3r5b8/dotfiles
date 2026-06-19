return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "auto",
				background = {
					light = "latte",
					dark = "mocha",
				},
				color_overrides = {
					latte = {
						base = "#ffffff",
						mantle = "#eff0f1",
						crust = "#dce0e4",

						text = "#232629",
						subtext1 = "#4c4f69",
						subtext0 = "#707d8a",

						overlay0 = "#9ca0b0",
						overlay1 = "#a1a9b1",
						overlay2 = "#bcc0cc",

						blue = "#3daee9",
						lavender = "#2980b9",
						sapphire = "#1d99f3",

						green = "#27ae60",
						teal = "#2980b9",
						sky = "#3daee9",

						yellow = "#f67400",
						peach = "#f67400",
						maroon = "#da4453",
						red = "#da4453",
					},

					mocha = {
						base = "#202326",
						mantle = "#1e2227",
						crust = "#292c30",

						text = "#fcfcfc",
						subtext1 = "#a1a9b1",
						subtext0 = "#707d8a",

						overlay0 = "#4a4f57",
						overlay1 = "#a1a9b1",
						overlay2 = "#bcc0cc",

						blue = "#3daee9",
						lavender = "#2980b9",
						sapphire = "#1d99f3",

						green = "#27ae60",
						teal = "#2980b9",
						sky = "#3daee9",

						yellow = "#f67400",
						peach = "#f67400",
						maroon = "#da4453",
						red = "#da4453",
					},
				},
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"f-person/auto-dark-mode.nvim",
		opts = {},
	},
}

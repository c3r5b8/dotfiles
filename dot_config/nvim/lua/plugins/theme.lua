return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				background = {
					light = "latte",
					dark = "mocha",
				},
				color_overrides = {
					latte = {
						base = "#ffffff",
						mantle = "#fcfcfc",
						crust = "#eff0f1",
						surface0 = "#eff0f1",
						surface1 = "#e0e2e5",
						surface2 = "#d0d5d9",

						text = "#232629",
						subtext1 = "#4d545b",
						subtext0 = "#5e6468",
						overlay2 = "#7f8c8d",
						overlay1 = "#95a5a6",
						overlay0 = "#bdc3c7",

						blue = "#1d99f3",
						sapphire = "#1d72b8",
						sky = "#3daee9",
						lavender = "#1d72b8",

						teal = "#0f8272",
						green = "#27ae60",
						yellow = "#d37c00",
						peach = "#e67e22",
						red = "#da4453",
						maroon = "#c0392b",

						mauve = "#8e44ad",
						pink = "#9b59b6",
						flamingo = "#e74c3c",
						rosewater = "#d35400",
					},

					mocha = {
						base = "#232629",
						mantle = "#1b1e20",
						crust = "#181b1d",
						surface0 = "#2a2e32",
						surface1 = "#31363b",
						surface2 = "#3d444b",

						text = "#eff0f1",
						subtext1 = "#bdc3c7",
						subtext0 = "#a1a8ad",
						overlay2 = "#7f8c8d",
						overlay1 = "#616a72",
						overlay0 = "#4d545b",

						blue = "#3daee9",
						sapphire = "#1d99f3",
						sky = "#3daee9",
						lavender = "#2980b9",

						teal = "#1caf9a",
						green = "#27ae60",
						yellow = "#f67400",
						peach = "#fca809",
						red = "#da4453",
						maroon = "#bd2c00",

						mauve = "#9b59b6",
						pink = "#8e44ad",
						flamingo = "#e67e22",
						rosewater = "#f39c12",
					},
				},
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"f-person/auto-dark-mode.nvim",
		opts = {
			update_interval = 1000,
			set_dark_mode = function()
				vim.api.nvim_set_option_value("background", "dark", {})
				vim.cmd.colorscheme("catppuccin")
			end,
			set_light_mode = function()
				vim.api.nvim_set_option_value("background", "light", {})
				vim.cmd.colorscheme("catppuccin")
			end,
		},
	},
}

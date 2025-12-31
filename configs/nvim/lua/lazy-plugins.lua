package.loaded["lspconfig"] = nil
package.loaded["lspconfig.configs"] = nil
require("lazy").setup({
	require("plugins/autopairs"),
	require("plugins/cmp"),
	require("plugins/conform"),
	require("plugins/debug"),
	require("plugins/gitsigns"),
	require("plugins/lint"),
	require("plugins/lspconfig"),
	require("plugins/mini"),
	require("plugins/telescope"),
	require("plugins/theme"),
	require("plugins/todo-comments"),
	require("plugins/treesitter"),
	require("plugins/which-key"),
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

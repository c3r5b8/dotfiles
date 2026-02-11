return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
				"bash",
				"c",
				"diff",
				"nix",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			})
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					local lang = ev.match
					local ignore_patterns = {
						"org",
						"fidget",
						"blink",
						"telescope",
					}
					for _, pattern in ipairs(ignore_patterns) do
						if lang:find(pattern) then
							return
						end
					end
					local ts = require("nvim-treesitter")
					local ok, task = pcall(ts.install, { lang }, { summary = false })
					if ok then
						task:wait(10000)
					end
					pcall(vim.treesitter.start, ev.buf, lang)
					if lang == "ruby" then
						vim.cmd("syntax on") -- Attempt to enable legacy syntax highlighting alongside Treesitter
					end
					if lang ~= "ruby" then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
}

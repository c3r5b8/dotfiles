-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- set correct ft for docker compose
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = {
		"docker-compose.yml",
		"docker-compose.yaml",
		"compose.yml",
		"compose.yaml",
	},
	callback = function()
		vim.bo.filetype = "yaml.docker-compose"
	end,
	desc = "Set filetype for Docker Compose files",
})

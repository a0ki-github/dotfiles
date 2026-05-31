local autocmd = vim.api.nvim_create_autocmd

-- バッファを閉じたときのカーソル位置の記憶
autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		vim.api.nvim_exec('silent! normal! g`"zv', false)
	end,
})

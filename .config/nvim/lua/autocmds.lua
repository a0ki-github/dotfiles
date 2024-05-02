local autocmd = vim.api.nvim_create_autocmd

-- プラグイン編集時に自動でPackerCompile
autocmd("BufWritePost", {
  pattern = { "plugins.lua" },
  command = "PackerCompile",
})

-- バッファを閉じたときのカーソル位置の記憶
autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		vim.api.nvim_exec('silent! normal! g`"zv', false)
	end,
})

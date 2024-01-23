local autocmd = vim.api.nvim_create_autocmd

-- プラグイン編集時に自動でPackerCompile
autocmd("BufWritePost", {
  pattern = { "plugins.lua" },
  command = "PackerCompile",
})

-- 一部言語でインデントを4に
autocmd("FileType", {
  pattern = {"php", "python"},
  callback = function()
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.softtabstop = 4
  end
})

-- バッファを閉じたときのカーソル位置の記憶
autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		vim.api.nvim_exec('silent! normal! g`"zv', false)
	end,
})

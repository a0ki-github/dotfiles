local autocmd = vim.api.nvim_create_autocmd

-- コメント行での改行時、自動でコメントにならないように
autocmd("BufEnter", {
	pattern = "*",
	command = "set fo-=c fo-=r fo-=o",
})

-- プラグイン編集時に自動でPackerCompile
autocmd("BufWritePost", {
  pattern = { "plugins.lua" },
  command = "PackerCompile",
})

-- 一部言語でインデントを4に
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"php", "python"},
  callback = function()
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.softtabstop = 4
  end
})

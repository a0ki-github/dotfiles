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

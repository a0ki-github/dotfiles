local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "tomtom/tcomment_vim",
  "Vimjas/vim-python-pep8-indent",
  { "rhysd/git-messenger.vim", cmd = { "GitMessenger" } },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = { "markdown" },
  },
  -- LSP & Mason
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  -- 補完
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/vim-vsnip",
  "hrsh7th/cmp-vsnip",
  "hrsh7th/cmp-cmdline",
  -- その他
  "github/copilot.vim",
  {
    "nvim-flutter/flutter-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
})

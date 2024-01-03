-- This file can be loaded by calling `lua require("plugins")` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require("packer").startup(function(use)
  -- Packer can manage itself
  use "wbthomason/packer.nvim"

  -- コメントアウトのショートカット
  use "tomtom/tcomment_vim"

  -- 括弧やブロックなどのペア間のジャンプなど
  use {"andymass/vim-matchup", event = "VimEnter"}

  -- コミット履歴などの確認
  use { "rhysd/git-messenger.vim", opt = true, cmd = { "GitMessenger" } }
  
  -- ファイルあいまい検索
  use { "ibhagwan/fzf-lua",
    -- optional for icon support
    requires = { "nvim-tree/nvim-web-devicons" },
  }
end)

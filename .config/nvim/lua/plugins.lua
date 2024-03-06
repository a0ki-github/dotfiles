-- This file can be loaded by calling `lua require("plugins")` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require("packer").startup(
  function(use)
    -- Packer can manage itself
    use "wbthomason/packer.nvim"

    -- コメントアウトのショートカット
    use "tomtom/tcomment_vim"

    use "Vimjas/vim-python-pep8-indent"

    -- 括弧やブロックなどのペア間のジャンプなど
    use {"andymass/vim-matchup", event = "VimEnter"}

    -- コミット履歴などの確認
    use { "rhysd/git-messenger.vim", opt = true, cmd = { "GitMessenger" } }

    -- ファイルあいまい検索
    use { "ibhagwan/fzf-lua",
      -- optional for icon support
      requires = { "nvim-tree/nvim-web-devicons" },
    }

    -- syntax highlight
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }

    -- マークダウンプレビュー
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })

    use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })

    -- lsp
    use {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
    }
    use "hrsh7th/nvim-cmp" --補完エンジン本体
    use "hrsh7th/cmp-nvim-lsp" --LSPを補完ソースに
    use "hrsh7th/cmp-buffer"  --bufferを補完ソースに
    use "hrsh7th/cmp-path"  --pathを補完ソースに
    use "hrsh7th/vim-vsnip" --スニペットエンジン
    use "hrsh7th/cmp-vsnip" --スニペットを補完ソースに
    use "hrsh7th/cmp-cmdline" -- コマンドモードでの補完

    use "github/copilot.vim"
  end)

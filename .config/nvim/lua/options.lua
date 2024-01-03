local options = {
	encoding = "utf-8",        -- ファイルのエンコーディングをUTF-8に設定
	fileencoding = "utf-8",    -- ファイルの書き込みエンコーディングをUTF-8に設定
	clipboard = "unnamedplus", -- ヤンクとクリップボードを連動
	backup = false,            -- バックアップファイルの作成を無効化
	writebackup = false,       -- 書き込み時バックアップの作成を無効化
	completeopt = {            -- 補完オプションの設定
    "menuone",  -- 候補が1つしかないときもポップアップメニューを使う。
    "noinsert", -- いかなるマッチしたテキストも、ユーザーがメニューから選択しない限り挿入しない。
    "noselect", -- メニューからマッチを自動選択せず、ユーザーに自分で選ぶことを強制する。
  },
	hlsearch = true,           -- 検索文字列のハイライトを有効化
	swapfile = false,          -- スワップファイル(.swp)を無効化
	termguicolors = true,      -- ターミナルでのGUIカラーを有効化
	expandtab = true,          -- タブをスペースに変換
	shiftwidth = 2,            -- インデントの幅（スペース数）
	smartindent = true,        -- スマートインデントを有効化
	tabstop = 2,               -- タブの幅
	undofile = true,           -- 一度閉じたファイルもundoできるように
	number = true,             -- 行番号の表示
	wrap = false,              -- 自動折り返しを無効化

  -- TODO 試してみて不要なら削除
	--shell = "fish",          -- シェルとしてfishを使用
	--timeoutlen = 300,        -- キーマップシーケンスの待機時間（ミリ秒）
	--updatetime = 300,        -- アップデートの待機時間（ミリ秒）
}

-- 定義したオプションを適用
for k, v in pairs(options) do
	vim.opt[k] = v
end

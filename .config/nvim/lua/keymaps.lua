local opts = { noremap = true, silent = false }
local keymap = vim.api.nvim_set_keymap
--[[
Modes
   normal_mode = 'n',
   insert_mode = 'i',
   visual_mode = 'v',
   visual_block_mode = 'x',
   term_mode = 't',
   command_mode = 'c',
--]]

--[[
  Normal
--]]

-- ウィンドウ作成
keymap("n", "ss", ":split<Return><C-w>w", opts)
keymap("n", "sv", ":vsplit<Return><C-w>w", opts)
-- ウィンドウ移動
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- 全選択
keymap("n", "<C-a>", "gg<S-v>G", opts)

-- ;でコマンド入力
keymap("n", ";", ":", opts)

-- Yで行ヤンクにする
keymap("n", "Y", "yy", opts)

-- <Space>q で強制終了
keymap("n", "q<Space>", ":q<Return>", opts)

-- ESC*2 でハイライトやめる
keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)


--[[

Insert

--]]

-- 括弧関連
keymap("i", "(<Enter>", "()<Left><CR><ESC><S-o><tab>", opts)
keymap("i", "{<Enter>", "{}<Left><CR><ESC><S-o><tab>", opts)
keymap("i", "[<Enter>", "[]<Left><CR><ESC><S-o><tab>", opts)
keymap("i", "(", "()<Left>", opts)
keymap("i", "{", "{}<Left>", opts)
keymap("i", "[", "[]<Left>", opts)
keymap("i", '"', '""<Left>', opts)
keymap("i", "'", "''<Left>", opts)
keymap("i", ")", "<Right>", opts)
keymap("i", "}", "<Right>", opts)
keymap("i", "]", "<Right>", opts)

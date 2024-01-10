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

-- 全選択
keymap("n", "<C-a>", "gg<S-v>G", opts)

-- Yで行ヤンクにする
keymap("n", "Y", "yy", opts)

-- <Space>q で強制終了
keymap("n", "q<Space>", ":q!<Return>", opts)

-- 前後のバッファに移動
keymap("n", "<C-[>", "<cmd>bprev<CR>", opts)
keymap("n", "<C-]>", "<cmd>bnext<CR>", opts)

-- LSP関連
keymap("n", "<C-b>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts) -- 定義ジャンプ
keymap("n", "<C-h>", "<cmd>lua vim.lsp.buf.hover()<CR>", opts) -- ホバー

--[[

Insert
--]]

-- 括弧関連
keymap("i", "(<Enter>", "()<Left><CR><ESC><S-o>", opts)
keymap("i", "{<Enter>", "{}<Left><CR><ESC><S-o>", opts)
keymap("i", "[<Enter>", "[]<Left><CR><ESC><S-o>", opts)
keymap("i", "(", "()<Left>", opts)
keymap("i", "{", "{}<Left>", opts)
keymap("i", "[", "[]<Left>", opts)
keymap("i", '"', '""<Left>', opts)
keymap("i", "'", "''<Left>", opts)
keymap("i", ")", "<Right>", opts)
keymap("i", "}", "<Right>", opts)
keymap("i", "]", "<Right>", opts)

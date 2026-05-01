require("flutter-tools").setup {
  -- 保存したときに自動でホットリロード
  hot_reload_on_save = true,
  -- :FlutterRun したときのデフォルトの引数を指定
  -- default_run_args = {
  --   flutter = { "-d", "00008110-00022C242607A01E" },
  -- },
  lsp = {
    -- 保存時に自動でフォーマット（インデント等）を整える設定
    color_capabilities = true,
    settings = {
      showTodos = true,
      completeFunctionCalls = true,
    },
  },
}

-- キーマッピング
vim.g.mapleader = " "
local map = vim.keymap.set
map("n", "<leader>r", "<cmd>FlutterRun<CR>",        { desc = "Flutter Run" })
map("n", "<leader>q", "<cmd>FlutterQuit<CR>",       { desc = "Flutter Quit" })
map("n", "<leader>R", "<cmd>FlutterRestart<CR>",    { desc = "Flutter Hot Restart" })
map("n", "<leader>l", "<cmd>FlutterLogToggle<CR>",  { desc = "Flutter Log Toggle" })

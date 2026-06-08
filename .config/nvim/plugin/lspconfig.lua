local mason_packages = vim.fn.stdpath('data') .. '/mason/packages'
local vue_language_server = mason_packages .. '/vue-language-server/node_modules/@vue/language-server'

require("mason").setup()

require("mason-tool-installer").setup({
  ensure_installed = {
    "stylua",
    "prettier",
    "black",
  },
})

vim.diagnostic.config({
  virtual_text = true,
})

-- Vue (Volar) は hybrid mode 仕様: vue_ls に tsdk を渡し、TS は ts_ls + @vue/typescript-plugin が担当する
vim.lsp.config('vue_ls', {
  init_options = {
    typescript = {
      tsdk = mason_packages .. '/vue-language-server/node_modules/typescript/lib',
    },
  },
})

vim.lsp.config('ts_ls', {
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = vue_language_server .. '/node_modules/@vue/typescript-plugin',
        languages = { 'vue' },
      },
    },
  },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
})


vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = 'standard',
      },
    },
  },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "basedpyright",
    "vue_ls",
    "ts_ls",
    "intelephense",
  },
  automatic_enable = true,
})

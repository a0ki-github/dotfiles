require("mason").setup()

require("mason-tool-installer").setup({
  ensure_installed = {
    -- LSP servers
    "lua-language-server",
    "python-lsp-server",
    "intelephense",
    "vue-language-server",
    -- Formatters
    "stylua",
    "prettier",
    "black",
  },
})

require("mason-lspconfig").setup({
  automatic_enable = true,
})

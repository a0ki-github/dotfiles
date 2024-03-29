--補完関係の設定
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  sources = { 
    { name = "nvim_lsp" }, --ソース類を設定
    { name = 'vsnip' }, -- For vsnip users.
    { name = "buffer" },
    { name = "path" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(), --Ctrl+pで補完欄を一つ上に移動
    ["<C-n>"] = cmp.mapping.select_next_item(), --Ctrl+nで補完欄を一つ下に移動
    ['<C-l>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ["<Enter>"] = cmp.mapping.confirm({ select = true }), --Enterで補完を選択確定
  }),
  experimental = {
    ghost_text = false,
  },
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

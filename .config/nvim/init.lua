if vim.g.vscode then
  -- VSCodeから起動された場合
  require('vscode-settings')
  require("base")
  require("options")
  require("keymaps")

  return
end

require("base")
require("colorscheme")
require("options")
require("autocmds")
require("keymaps")
require("plugins")

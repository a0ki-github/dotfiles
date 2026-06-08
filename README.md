# dotfiles

## セットアップ

### 1. 前提ツールのインストール

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install neovim tmux fzf git-lfs pyenv rbenv nodenv node
```

### 2. リポジトリのクローン

```bash
git clone https://github.com/a0ki-github/dotfiles.git ~/dotfiles
```

### 3. シンボリックリンクの作成

```bash
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.vimrc ~/.vimrc
mkdir -p ~/.config
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
mkdir -p ~/.zsh
ln -s ~/dotfiles/.zsh/git-completion.zsh ~/.zsh/git-completion.zsh
ln -s ~/dotfiles/.zsh/git-prompt.sh ~/.zsh/git-prompt.sh
ln -s ~/dotfiles/.zsh/git-prompt.sh ~/.git-prompt.sh
```

### 4. Neovim の初回起動

```bash
nvim
```

`nvim` を起動すると lazy.nvim が自動インストールされ、続いて全プラグイン・LSP サーバ・フォーマッタが自動セットアップされる。完了後は `nvim` を再起動する。

### 5. GitHub Copilot の認証

```vim
:Copilot setup
```

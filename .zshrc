export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export EDITOR="nvim"
eval "$(pyenv init -)"
eval "$(rbenv init -)"
eval "$(nodenv init -)"
bindkey -e

# tkinterのための設定
export LDFLAGS="-L$(brew --prefix tcl-tk)/lib"
export CPPFLAGS="-I$(brew --prefix tcl-tk)/include"
export PKG_CONFIG_PATH="$(brew --prefix tcl-tk)/lib/pkgconfig"
export PATH="$(brew --prefix tcl-tk)/bin:$PATH"

# Avoid accidental deletion
alias vim='nvim'
alias vw="view"
alias n='nvim'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias c='code'
alias be='bundle exec'
alias ll='ls -la'
alias ls="ls -GF"
alias gls="gls --color"
alias rb="ruby"
alias py="python3"
alias par="php artisan"
alias f='nvim $(find . -type f -not -path "*/.git/*" -not -path "*/node_modules/*" | fzf)'
alias tnew='tmux new -s $(basename "$PWD")'
alias ta='tmux attach-session -t $(tmux list-sessions -F "#{session_name}" | fzf)'

# 仕事関係
alias mar="./mac artisan"
alias csfix="./run.sh pcf:fix"
alias csfixall="./run.sh pcf:fix-all"
alias lys="./run.sh lrs:analyse"
alias lysb="./run.sh lrs:generate-baseline"
alias psqld="docker run --rm -it --net=host postgres:12 psql"

# Prevent rm -f from asking for confirmation on things like `rm -f *.bak`.
setopt rm_star_silent

# Customize prompt to show only working directory.
PS1='[%1~]$ '

# Prompt configuration
source ~/.git-prompt.sh
setopt PROMPT_SUBST
PS1='[%1~$(__git_ps1 " (%s)")]\$ '

# Git completion
fpath=(~/.zsh $fpath)
autoload -Uz compinit && compinit

# 色を使用
autoload -U compinit
compinit

export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

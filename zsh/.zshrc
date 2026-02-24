# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history hist_ignore_dups hist_ignore_space

# Options
setopt auto_cd correct interactive_comments

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''

# Keybinds (vi mode)
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# Minimal monochrome prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt prompt_subst

PROMPT='%F{white}%~%f%F{240}${vcs_info_msg_0_}%f %F{white}❯%f '

# Aliases
alias ls='ls --color=auto'
alias la='ls -lah'
alias ll='ls -lh'
alias grep='grep --color=auto'
alias cat='bat --theme=base16'
alias vim='nvim'
alias v='nvim'
alias g='git'
alias t='tmux'
alias ta='tmux attach -t'
alias tn='tmux new -s'

# Env
export EDITOR='nvim'
export VISUAL='nvim'
export TERM='alacritty'
export PATH="$HOME/.local/bin:$PATH"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# fzf
source /usr/share/fzf/key-bindings.zsh 2>/dev/null
source /usr/share/fzf/completion.zsh 2>/dev/null
export FZF_DEFAULT_OPTS='--color=bg+:#0d0d0d,bg:#000000,spinner:#ffffff,hl:#777777,fg:#cccccc,header:#444444,info:#777777,pointer:#ffffff,marker:#ffffff,fg+:#ffffff,prompt:#444444,hl+:#ffffff --border sharp'

# History
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.cache/zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

# Completion
autoload -U compinit && compinit -C
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:*:*:*' menu select

# Keybindings (vi mode)
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# Aliases
alias ls='ls --color=auto -h'
alias ll='ls -lah'
alias la='ls -A'
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias df='df -h'
alias du='du -h'
alias ps='ps aux'
alias tree='tree -L 2'

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gs='git status'
alias gd='git diff'

# Productivity
alias sudo='sudo '

# Dev aliases
alias python='python3'
alias py='python3'

# Tmux (suppress warnings)
if (( ${+commands[tmux]} )); then
    alias tmux='tmux 2>&1 | grep -v libseat'
fi

# Security/CSIRT
alias nmap-quick='nmap -sV -p- --open'
alias nmap-stealth='nmap -sS -p- --open'
alias check-ports='ss -tlnp'
alias check-processes='ps aux | grep -v grep'
alias find-binaries='find / -type f -perm /4000 2>/dev/null'
alias dns-flush='sudo systemctl restart systemd-resolved'

# Log analysis
alias logs-errors='journalctl -p err -n 50'
alias logs-warnings='journalctl -p warning -n 50'
alias audit-recent='auditctl -l'

# System
alias sys-stats='uname -a && lsb_release -a'
alias disk-usage='du -sh *'
alias mem-usage='free -h'

# Directory bookmarks
alias work='cd ~/work'
alias projects='cd ~/projects'
alias src='cd ~/src'
alias config='cd ~/.config'
alias downloads='cd ~/Downloads'

# Enable prompt command substitution
setopt PROMPT_SUBST

eval "$(starship init zsh)"

# No beep
setopt NO_BEEP
setopt NOTIFY

# Performance
setopt MENU_COMPLETE

export PATH="$HOME/.local/bin:$PATH"

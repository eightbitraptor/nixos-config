# Disable greeting
set -g fish_greeting

# Environment variables
set -gx EDITOR vim
set -gx VISUAL vim

# FZF configuration
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'

# Colored man pages
set -gx LESS_TERMCAP_mb \e'[1;32m'
set -gx LESS_TERMCAP_md \e'[1;32m'
set -gx LESS_TERMCAP_me \e'[0m'
set -gx LESS_TERMCAP_se \e'[0m'
set -gx LESS_TERMCAP_so \e'[01;33m'
set -gx LESS_TERMCAP_ue \e'[0m'
set -gx LESS_TERMCAP_us \e'[1;4;31m'

# Add paths
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.rubies/ruby-*/bin

# Pywal integration (if available)
if command -q wal
  cat ~/.cache/wal/sequences &
end

# SSH agent
if test -z "$SSH_AUTH_SOCK"
  eval (ssh-agent -c) >/dev/null
end

# Direnv hook
direnv hook fish | source

# Ruby environment (if available)
if test -d /usr/share/chruby
  source /usr/share/chruby/chruby.fish
  source /usr/share/chruby/auto.fish
end

# Node version manager (if available)
if type -q nvm
  nvm use default 2>/dev/null
end

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Modern replacements
alias ls='eza'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias ps='procs'
alias du='dust'
alias df='duf'
alias top='btop'

# Ruby/Rails
alias be='bundle exec'
alias rs='rails server'
alias rc='rails console'

# NixOS
alias rebuild='sudo nixos-rebuild switch --flake ~/git/dotfiles/nixos-config#fern'
alias update='nix flake update ~/git/dotfiles/nixos-config'
alias clean='sudo nix-collect-garbage -d'

# Tmux
alias ta='tmux attach -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'

# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# Config shortcuts
alias fishconfig='vim ~/.config/fish/config.fish'
alias vimrc='vim ~/.vimrc'
alias swayconfig='vim ~/.config/sway/config'
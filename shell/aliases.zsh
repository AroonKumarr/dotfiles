# Better directory listings with eza
if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias l='eza -lah'
  alias ll='eza -lah'
  alias la='eza -a'
  alias lt='eza --tree --level=2'
fi

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias dotfiles='cd ~/.dotfiles'

# Homebrew environment
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'
command -v fd >/dev/null 2>&1 && alias fdfind='fd'

[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

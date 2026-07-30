if command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
  alias cat='batcat --paging=never'
elif command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi

if command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

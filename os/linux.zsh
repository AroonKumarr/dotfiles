# Ubuntu packages use different executable names
if command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
  alias cat='batcat --paging=never'
fi

if command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

# Load fzf configuration when available
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# Homebrew on Apple Silicon
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# macOS command names
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'
command -v fd >/dev/null 2>&1 && alias fdfind='fd'

# Load fzf configuration when available
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

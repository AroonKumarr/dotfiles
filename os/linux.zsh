if command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
  alias cat='batcat --paging=never'
elif command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi

if command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

# WSL (Windows Subsystem for Linux) conveniences
if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
  command -v explorer.exe >/dev/null 2>&1 && alias explorer='explorer.exe'
  if command -v wslview >/dev/null 2>&1; then
    alias open='wslview'
  elif command -v explorer.exe >/dev/null 2>&1; then
    alias open='explorer.exe'
  fi
  command -v clip.exe >/dev/null 2>&1 && alias clip='clip.exe'
fi

[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

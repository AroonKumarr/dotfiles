# Windows-specific shell configuration (Git Bash / MSYS2 / Cygwin)

# bat aliases
if command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
  alias cat='batcat --paging=never'
elif command -v bat >/dev/null 2>&1 || command -v bat.exe >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi

# fd alias
if command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

# Windows interop shortcuts
command -v explorer.exe >/dev/null 2>&1 && alias explorer='explorer.exe'
command -v clip.exe >/dev/null 2>&1 && alias clip='clip.exe'

if command -v start >/dev/null 2>&1; then
  alias open='start'
elif command -v explorer.exe >/dev/null 2>&1; then
  alias open='explorer.exe'
fi

[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

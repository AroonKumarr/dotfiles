# Create a directory and enter it.
mkcd() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: mkcd <directory>"
    return 2
  fi

  mkdir -p -- "$1" && cd -- "$1"
}

# Extract common archive formats.
extract() {
  if [[ $# -ne 1 || ! -f "$1" ]]; then
    echo "Usage: extract <archive>"
    return 2
  fi

  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.tbz2)    tar xjf "$1" ;;
    *.tgz)     tar xzf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.7z)      7z x "$1" ;;
    *)         echo "Unsupported archive: $1"; return 1 ;;
  esac
}

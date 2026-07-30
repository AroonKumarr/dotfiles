#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/AroonKumarr/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

if ! command -v git >/dev/null 2>&1; then
  case "$(uname -s)" in
    Darwin)
      echo "Git is required. Install Apple's Command Line Tools with: xcode-select --install"
      exit 1
      ;;
    Linux)
      sudo apt-get update
      sudo apt-get install -y git
      ;;
    *)
      echo "Unsupported operating system."
      exit 1
      ;;
  esac
fi

if [[ -d "$DOTFILES_DIR/.git" ]]; then
  echo "Updating existing dotfiles repository..."
  git -C "$DOTFILES_DIR" pull --ff-only
elif [[ -e "$DOTFILES_DIR" ]]; then
  echo "Error: $DOTFILES_DIR exists but is not a Git repository."
  echo "Move or remove it, then run this script again."
  exit 1
else
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

exec "$DOTFILES_DIR/install.sh"

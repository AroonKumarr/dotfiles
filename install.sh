#!/usr/bin/env bash
set -Eeuo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$SCRIPT_DIR" != "$DOTFILES_DIR" ]]; then
  DOTFILES_DIR="$SCRIPT_DIR"
fi

source "$DOTFILES_DIR/scripts/common.sh"

main() {
  print_header "Aroon Dotfiles Installer"
  require_supported_os

  case "$(uname -s)" in
    Darwin)
      source "$DOTFILES_DIR/scripts/macos.sh"
      install_macos_packages
      ;;
    Linux)
      source "$DOTFILES_DIR/scripts/ubuntu.sh"
      install_ubuntu_packages
      ;;
  esac

  install_oh_my_zsh
  install_zsh_plugins
  create_dotfile_links
  ensure_local_bin_on_path
  set_default_shell

  print_success "Installation complete."
  printf '\nStart a new terminal session, or run:\n\n  exec zsh\n\n'
}

main "$@"

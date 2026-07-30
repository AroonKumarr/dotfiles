#!/usr/bin/env bash

install_ubuntu_packages() {
  print_header "Installing Ubuntu packages"

  sudo apt-get update
  sudo apt-get install -y \
    zsh \
    git \
    curl \
    eza \
    bat \
    fd-find \
    ripgrep \
    fzf

  print_info "Ubuntu uses command names batcat and fdfind."
  print_info "Aliases in os/linux.zsh expose them as bat and fd."
}

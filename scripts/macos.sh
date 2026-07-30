#!/usr/bin/env bash

install_macos_packages() {
  print_header "Installing macOS packages"

  if ! command_exists brew; then
    print_info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  local packages=(zsh git eza bat fd ripgrep fzf)
  brew install "${packages[@]}"

  if brew info --cask font-meslo-lg-nerd-font >/dev/null 2>&1; then
    brew install --cask font-meslo-lg-nerd-font || true
  else
    print_warning "MesloLGS Nerd Font cask was not found. Install a Nerd Font manually if icons are missing."
  fi

  if [[ -x "$(brew --prefix)/opt/fzf/install" ]]; then
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc || true
  fi
}

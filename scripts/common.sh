#!/usr/bin/env bash

print_header() {
  printf '\n\033[1;36m==> %s\033[0m\n' "$1"
}

print_info() {
  printf '\033[1;34m[INFO]\033[0m %s\n' "$1"
}

print_success() {
  printf '\033[1;32m[OK]\033[0m %s\n' "$1"
}

print_warning() {
  printf '\033[1;33m[WARN]\033[0m %s\n' "$1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_supported_os() {
  case "$(uname -s)" in
    Darwin) print_info "Detected macOS." ;;
    Linux)
      if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        if [[ "${ID:-}" != "ubuntu" && "${ID_LIKE:-}" != *"ubuntu"* && "${ID_LIKE:-}" != *"debian"* ]]; then
          print_warning "This installer is tested on Ubuntu. Continuing cautiously."
        fi
      fi
      if grep -qi microsoft /proc/version 2>/dev/null || [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        print_info "Detected Linux (WSL)."
      else
        print_info "Detected Linux."
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      print_info "Detected Windows ($(uname -s))."
      ;;
    *)
      echo "Unsupported operating system: $(uname -s)"
      exit 1
      ;;
  esac
}

clone_or_update() {
  local repo="$1"
  local destination="$2"

  if [[ -d "$destination/.git" ]]; then
    print_info "Updating $(basename "$destination")..."
    git -C "$destination" pull --ff-only || print_warning "Could not update $destination; keeping the installed version."
  elif [[ -e "$destination" ]]; then
    print_warning "$destination exists and is not a Git repository; leaving it unchanged."
  else
    print_info "Installing $(basename "$destination")..."
    git clone --depth=1 "$repo" "$destination"
  fi
}

install_oh_my_zsh() {
  if ! command_exists zsh; then
    print_warning "Zsh is not installed. Skipping Oh My Zsh installation."
    return
  fi

  if [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
    print_success "Oh My Zsh is already installed."
    return
  fi

  print_header "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_zsh_plugins() {
  if ! command_exists zsh; then
    return
  fi

  print_header "Installing Zsh theme and plugins"
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  clone_or_update \
    "https://github.com/romkatv/powerlevel10k.git" \
    "$custom_dir/themes/powerlevel10k"

  clone_or_update \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$custom_dir/plugins/zsh-autosuggestions"

  clone_or_update \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$custom_dir/plugins/zsh-syntax-highlighting"
}

backup_path() {
  local target="$1"
  local backup_root="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$backup_root"
    mv "$target" "$backup_root/"
    print_info "Backed up $target to $backup_root/"
  fi
}

link_file() {
  local source_file="$1"
  local target_file="$2"

  if [[ -L "$target_file" ]] && [[ "$(readlink "$target_file")" == "$source_file" ]]; then
    print_success "$target_file is already linked."
    return
  fi

  backup_path "$target_file"
  if ln -s "$source_file" "$target_file" 2>/dev/null; then
    print_success "Linked $target_file -> $source_file"
  else
    cp -f "$source_file" "$target_file"
    print_warning "Symbolic link unavailable; copied $source_file to $target_file"
  fi
}

create_dotfile_links() {
  print_header "Creating configuration links"
  link_file "$DOTFILES_DIR/shell/zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/shell/p10k.zsh" "$HOME/.p10k.zsh"
}

ensure_local_bin_on_path() {
  mkdir -p "$HOME/.local/bin"

  local updater="$DOTFILES_DIR/bin/update-dotfiles"
  chmod +x "$updater"

  if [[ -L "$HOME/.local/bin/update-dotfiles" ]] && \
     [[ "$(readlink "$HOME/.local/bin/update-dotfiles")" == "$updater" ]]; then
    return
  fi

  rm -f "$HOME/.local/bin/update-dotfiles"
  if ln -s "$updater" "$HOME/.local/bin/update-dotfiles" 2>/dev/null; then
    :
  else
    cp -f "$updater" "$HOME/.local/bin/update-dotfiles"
  fi
}

set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"

  if [[ -z "$zsh_path" ]]; then
    print_warning "Zsh was not found; default shell was not changed."
    return
  fi

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    print_success "Zsh is already the default shell."
    return
  fi

  if ! command_exists chsh; then
    print_info "chsh is not available on this platform; skipping default shell change."
    return
  fi

  print_info "Attempting to set Zsh as the default shell."
  if chsh -s "$zsh_path"; then
    print_success "Default shell changed to Zsh."
  else
    print_warning "Could not change the default shell automatically."
    print_warning "Run this manually: chsh -s \"$zsh_path\""
  fi
}

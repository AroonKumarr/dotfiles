#!/usr/bin/env bash

install_windows_packages() {
  print_header "Setting up Windows packages"

  local winget_cmd=""
  if command_exists winget.exe; then
    winget_cmd="winget.exe"
  elif command_exists winget; then
    winget_cmd="winget"
  fi

  if [[ -n "$winget_cmd" ]]; then
    print_info "Found Windows Package Manager (winget)."

    local packages=(
      "eza-community.eza"
      "sharkdp.bat"
      "sharkdp.fd"
      "BurntSushi.ripgrep.MSVC"
      "junegunn.fzf"
    )

    for pkg in "${packages[@]}"; do
      print_info "Ensuring $pkg is installed..."
      "$winget_cmd" install --id "$pkg" -e --source winget \
        --accept-source-agreements --accept-package-agreements \
        --disable-interactivity >/dev/null 2>&1 || true
    done
  elif command_exists scoop; then
    print_info "Using Scoop package manager..."
    scoop install eza bat fd ripgrep fzf || true
  elif command_exists choco; then
    print_info "Using Chocolatey package manager..."
    choco install eza bat fd ripgrep fzf -y || true
  else
    print_warning "No supported Windows package manager (winget, scoop, or choco) found in PATH."
  fi

  print_info "Windows environment detected."
  print_info "For the native PowerShell experience and Oh My Posh prompt, run: .\\install.ps1 in PowerShell."
}

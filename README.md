# Aroon's Dotfiles

A clean, cross-platform terminal and shell setup for **macOS**, **Ubuntu / Linux**, and **Windows**.

## What it installs

### macOS & Linux
- Zsh & Oh My Zsh
- Powerlevel10k theme
- MesloLGS Nerd Font (via Homebrew on macOS)
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- Modern CLI utilities: `eza`, `bat`, `fd`, `ripgrep`, `fzf`
- Shared aliases and shell functions
- Safe backups and symbolic links

### Windows (PowerShell & Windows Terminal)
- PowerShell 7 and Windows PowerShell 5.1 configuration
- **Oh My Posh** with a prompt theme identical to Powerlevel10k
- **MesloLGS Nerd Font** (automated installation)
- **PSReadLine** with predictive history autocomplete & syntax highlighting (mirroring `zsh-autosuggestions` and `zsh-syntax-highlighting`)
- Modern CLI utilities via **winget** (or Scoop / Chocolatey): `eza`, `bat`, `fd`, `ripgrep`, `fzf`
- Identical aliases (`gs`, `ga`, `gc`, `gp`, `gl`, `ls` -> `eza`, `cat` -> `bat`, `..`, `...`, `dotfiles`)
- Identical helper functions (`mkcd`, `extract`, `update-dotfiles`)
- Windows Subsystem for Linux (WSL) and Git Bash / MSYS2 integrations

## Supported systems

- **macOS** with Apple Silicon or Intel
- **Ubuntu 22.04+** and Debian-based Linux distributions
- **Windows 10 & 11** (PowerShell 7+, Windows PowerShell 5.1, Windows Terminal, WSL, Git Bash)

---

## Quick installation

### On Windows (PowerShell)

Open **PowerShell** or **Windows Terminal** and run:

#### One-command installation
```powershell
irm https://raw.githubusercontent.com/AroonKumarr/dotfiles/main/bootstrap.ps1 | iex
```

#### Manual installation
```powershell
git clone https://github.com/AroonKumarr/dotfiles.git $HOME\.dotfiles
cd $HOME\.dotfiles
.\install.ps1
```

---

### On macOS & Linux (Zsh)

Open your terminal and run:

#### One-command installation
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AroonKumarr/dotfiles/main/bootstrap.sh)"
```

#### Manual installation
```bash
git clone https://github.com/AroonKumarr/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

---

## What the installer changes

### On macOS & Linux
Creates symbolic links:
```text
~/.zshrc     -> ~/.dotfiles/shell/zshrc
~/.p10k.zsh  -> ~/.dotfiles/shell/p10k.zsh
```

### On Windows
Creates symbolic links or safe profile loaders:
```text
Documents\PowerShell\Microsoft.PowerShell_profile.ps1        -> ~/.dotfiles/powershell/profile.ps1
Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -> ~/.dotfiles/powershell/profile.ps1
```
And adds `~/.dotfiles/bin` to the user's `PATH`.

### Backups
Existing configurations are automatically backed up inside:
```text
~/.dotfiles-backups/YYYYMMDD-HHMMSS/
```
The installer is idempotent and safe to run multiple times.

---

## Repository structure

```text
.
├── .gitignore
├── LICENSE
├── README.md
├── bootstrap.sh                 # One-liner bootstrap for macOS/Linux
├── bootstrap.ps1                # One-liner bootstrap for Windows PowerShell
├── install.sh                   # Main installer for macOS/Linux/Git Bash
├── install.ps1                  # Main installer for Windows PowerShell
├── bin/
│   ├── update-dotfiles          # Updater script for Unix/Git Bash
│   ├── update-dotfiles.ps1      # Updater script for PowerShell
│   └── update-dotfiles.cmd      # Updater launcher for Windows CMD/Terminal
├── git/
│   └── gitconfig.example        # Cross-platform Git configuration template
├── os/
│   ├── linux.zsh                # Linux & WSL-specific settings
│   ├── macos.zsh                # macOS Homebrew & tools
│   ├── windows.ps1              # Windows-specific PowerShell helpers
│   └── windows.zsh              # Windows Git Bash / MSYS2 settings
├── powershell/
│   ├── aliases.ps1              # PowerShell aliases (matching Zsh)
│   ├── functions.ps1            # PowerShell functions (mkcd, extract, etc.)
│   ├── p10k.omp.json            # Oh My Posh theme mirroring Powerlevel10k
│   └── profile.ps1              # Core PowerShell profile
├── scripts/
│   ├── common.sh                # Shared bash helper functions
│   ├── macos.sh                 # macOS package installer (Homebrew)
│   ├── ubuntu.sh                # Ubuntu package installer (APT)
│   ├── windows.ps1              # Windows package installer (winget/scoop)
│   └── windows.sh               # Git Bash package installer
├── shell/
│   ├── aliases.zsh              # Shared Zsh aliases
│   ├── functions.zsh            # Shared shell functions (mkcd, extract)
│   ├── p10k.zsh                 # Powerlevel10k theme configuration
│   └── zshrc                    # Core Zsh configuration
└── ssh/
    └── config.example           # SSH config template
```

---

## Shared Aliases & Commands

Both PowerShell (Windows) and Zsh (macOS/Linux) support the exact same workflow shortcuts:

| Command | Action |
| :--- | :--- |
| `ls` | Modern file list using `eza` |
| `l`, `ll` | Long format listing (`eza -lah`) |
| `la` | List all including hidden files (`eza -a`) |
| `lt` | Tree view (`eza --tree --level=2`) |
| `cat` | Syntax-highlighted file pager using `bat` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate` |
| `..`, `...` | Navigate up 1 or 2 directory levels |
| `dotfiles` | Navigate directly to the `~/.dotfiles` directory |
| `mkcd <dir>` | Create directory and immediately switch into it |
| `extract <file>` | Extract archive (`.tar.gz`, `.zip`, `.tar.bz2`, `.7z`, etc.) |
| `update-dotfiles` | Pull latest dotfiles and reapply configuration |

---

## Updating an existing machine

Run at any time:

```bash
update-dotfiles
```

Or on Windows in PowerShell:

```powershell
update-dotfiles
```

---

## Font setup

Both Powerlevel10k (macOS/Linux) and Oh My Posh (Windows) require a **Nerd Font** for glyphs and icons.

- **Windows**: The installer automatically runs `oh-my-posh font install meslo`. After installation, enable it in Windows Terminal:
  ```text
  Settings (Ctrl+,) → Defaults → Appearance → Font face → MesloLGS NF
  ```
- **macOS**: The installer installs `font-meslo-lg-nerd-font` through Homebrew. In Apple Terminal or iTerm2, set font to **MesloLGS NF**.
- **Ubuntu / WSL**: Set the font in your client terminal (e.g. Windows Terminal or local emulator).

---

## SSH & Git safety

This repository contains only example configurations (`git/gitconfig.example`, `ssh/config.example`).

Never commit:
- SSH private keys (`id_rsa`, `id_ed25519`)
- Passwords, personal access tokens, or API keys
- `.env` files or private server connection strings

---

## Customization

- **Windows (PowerShell)**:
  - Add or modify aliases in `powershell/aliases.ps1`
  - Add or modify functions in `powershell/functions.ps1`
  - Windows-specific tools in `os/windows.ps1`
- **macOS & Linux (Zsh)**:
  - Add or modify aliases in `shell/aliases.zsh`
  - Add or modify functions in `shell/functions.zsh`
  - OS-specific settings in `os/macos.zsh` or `os/linux.zsh`

---

## Uninstall or revert

### On Windows
Remove the profile loader or links:
```powershell
Remove-Item "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force -ErrorAction SilentlyContinue
```
Restore the previous profile from `~/.dotfiles-backups/`.

### On macOS & Linux
Remove the symbolic links:
```bash
rm ~/.zshrc ~/.p10k.zsh
```
Restore your backed up configuration from `~/.dotfiles-backups/`.

---

## License

MIT

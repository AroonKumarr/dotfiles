# Aroon's Dotfiles

A clean, cross-platform terminal setup for **macOS** and **Ubuntu**.

## What it installs

- Zsh
- Oh My Zsh
- Powerlevel10k
- MesloLGS Nerd Font on macOS
- zsh-autosuggestions
- zsh-syntax-highlighting
- eza
- bat
- fd
- ripgrep
- fzf
- Shared aliases and shell functions
- OS-specific configuration
- Safe backups and symbolic links

## Supported systems

- macOS with Apple Silicon or Intel
- Ubuntu 22.04 and newer

## Quick installation

### Normal installation

```bash
git clone https://github.com/AroonKumarr/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

### One-command installation

After this repository is uploaded to GitHub:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AroonKumarr/dotfiles/main/bootstrap.sh)"
```

## What the installer changes

The installer creates these symbolic links:

```text
~/.zshrc     -> ~/.dotfiles/shell/zshrc
~/.p10k.zsh  -> ~/.dotfiles/shell/p10k.zsh
```

Existing files are backed up inside:

```text
~/.dotfiles-backups/YYYYMMDD-HHMMSS/
```

The installer is designed to be safe to run more than once.

## Repository structure

```text
.
├── .gitignore
├── LICENSE
├── README.md
├── bootstrap.sh
├── install.sh
├── bin/
│   └── update-dotfiles
├── git/
│   └── gitconfig.example
├── os/
│   ├── linux.zsh
│   └── macos.zsh
├── scripts/
│   ├── common.sh
│   ├── macos.sh
│   └── ubuntu.sh
├── shell/
│   ├── aliases.zsh
│   ├── functions.zsh
│   ├── p10k.zsh
│   └── zshrc
└── ssh/
    └── config.example
```

## Updating an existing machine

```bash
update-dotfiles
```

Or manually:

```bash
cd ~/.dotfiles
git pull
./install.sh
```

## Font note

Powerlevel10k icons require a Nerd Font.

- On macOS, the installer installs **MesloLGS Nerd Font** through Homebrew.
- On Ubuntu Server, the font must be selected in the terminal application on the computer used to connect by SSH. The server itself does not render the terminal font.

For Apple Terminal, open:

```text
Terminal → Settings → Profiles → Text → Font
```

and select a MesloLGS Nerd Font.

## SSH safety

This repository contains only `ssh/config.example`.

Never commit:

- SSH private keys
- passwords
- access tokens
- `.env` files
- private server details that should not be public

## Customization

Edit:

```text
shell/aliases.zsh
shell/functions.zsh
os/macos.zsh
os/linux.zsh
```

Then commit your changes:

```bash
git add .
git commit -m "Update shell configuration"
git push
```

## Uninstall or revert

Remove the symbolic links:

```bash
rm ~/.zshrc ~/.p10k.zsh
```

Then restore the latest backup from:

```text
~/.dotfiles-backups/
```

This does not remove installed applications. Package removal should be handled through Homebrew or APT.

## License

MIT

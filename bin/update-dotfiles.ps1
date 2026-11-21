# Windows PowerShell Dotfiles Updater
# Aroon Kumar's Dotfiles

$DOTFILES_DIR = if ($env:DOTFILES) { $env:DOTFILES } else { Join-Path $HOME ".dotfiles" }

if (-not (Test-Path (Join-Path $DOTFILES_DIR ".git"))) {
    Write-Error "Dotfiles repository not found at $DOTFILES_DIR"
    exit 1
}

Write-Host "`n==> Updating dotfiles repository..." -ForegroundColor Cyan
git -C $DOTFILES_DIR pull --ff-only

$installer = Join-Path $DOTFILES_DIR "install.ps1"
if (Test-Path $installer) {
    & $installer
} else {
    Write-Error "Installer not found at $installer"
}

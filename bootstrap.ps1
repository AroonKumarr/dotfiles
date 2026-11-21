# Windows PowerShell Bootstrap Script
# Aroon Kumar's Dotfiles

$ErrorActionPreference = "Stop"

$REPO_URL = if ($env:DOTFILES_REPO_URL) { $env:DOTFILES_REPO_URL } else { "https://github.com/AroonKumarr/dotfiles.git" }
$DOTFILES_DIR = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { Join-Path $HOME ".dotfiles" }

Write-Host "`n==> Aroon Dotfiles Bootstrap (Windows)" -ForegroundColor Cyan

# Ensure Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[INFO] Git is not found. Attempting installation via winget..." -ForegroundColor Blue
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Git.Git -e --source winget `
            --accept-source-agreements --accept-package-agreements | Out-Null
        # Refresh environment path
        $env:PATH = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
    } else {
        Write-Error "Git is required. Install Git from https://git-scm.com or install winget, then run again."
        exit 1
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git is still not found in PATH. Please restart your terminal and run again."
    exit 1
}

# Clone or update dotfiles repository
if (Test-Path (Join-Path $DOTFILES_DIR ".git")) {
    Write-Host "[INFO] Updating existing dotfiles repository..." -ForegroundColor Blue
    git -C $DOTFILES_DIR pull --ff-only
} elseif (Test-Path $DOTFILES_DIR) {
    Write-Error "$DOTFILES_DIR exists but is not a Git repository. Move or remove it, then try again."
    exit 1
} else {
    Write-Host "[INFO] Cloning dotfiles to $DOTFILES_DIR..." -ForegroundColor Blue
    git clone $REPO_URL $DOTFILES_DIR
}

# Execute installer
$installer = Join-Path $DOTFILES_DIR "install.ps1"
if (Test-Path $installer) {
    & $installer
} else {
    Write-Error "Installer script not found at $installer"
    exit 1
}

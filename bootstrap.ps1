# Windows PowerShell Bootstrap Script - 1-Command Automated Installer
# Aroon Kumar's Dotfiles

$ErrorActionPreference = "Stop"

# Enable modern TLS
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Enable script execution for current user
try {
    $policy = Get-ExecutionPolicy -Scope CurrentUser
    if ($policy -notin @("RemoteSigned", "Unrestricted", "Bypass")) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    }
} catch {}

$REPO_URL = if ($env:DOTFILES_REPO_URL) { $env:DOTFILES_REPO_URL } else { "https://github.com/AroonKumarr/dotfiles.git" }
$DOTFILES_DIR = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { Join-Path $HOME ".dotfiles" }

Write-Host "`n==> Aroon Dotfiles Bootstrap (Windows)" -ForegroundColor Cyan

# Ensure Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[INFO] Git is not found. Attempting automatic installation via winget..." -ForegroundColor Blue
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Git.Git -e --source winget `
            --accept-source-agreements --accept-package-agreements `
            --disable-interactivity | Out-Null
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

# Execute installer with execution policy bypass
$installer = Join-Path $DOTFILES_DIR "install.ps1"
if (Test-Path $installer) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $installer
} else {
    Write-Error "Installer script not found at $installer"
    exit 1
}

# Immediately load profile in current session
$profilePath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Microsoft.PowerShell_profile.ps1"
if (-not (Test-Path $profilePath)) {
    $profilePath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
}

if (Test-Path $profilePath) {
    Write-Host "`n==> Activating your new shell environment..." -ForegroundColor Cyan
    . $profilePath
}

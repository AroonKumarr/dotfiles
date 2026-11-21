# Windows PowerShell Bootstrap Script - 1-Command Automated Installer
# Aroon Kumar's Dotfiles

$ErrorActionPreference = "Stop"

# Enable modern TLS (TLS 1.2 / 1.3)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Enable script execution for current user
try {
    $policy = Get-ExecutionPolicy -Scope CurrentUser
    if ($policy -notin @("RemoteSigned", "Unrestricted", "Bypass")) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    }
} catch {}

$REPO_URL = if ($env:DOTFILES_REPO_URL) { $env:DOTFILES_REPO_URL } else { "https://github.com/AroonKumarr/dotfiles.git" }
$ZIP_URL  = "https://github.com/AroonKumarr/dotfiles/archive/refs/heads/main.zip"
$DOTFILES_DIR = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { Join-Path $HOME ".dotfiles" }

Write-Host "`n==> Aroon Dotfiles Bootstrap (Windows)" -ForegroundColor Cyan

function Refresh-EnvironmentPath {
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath    = [Environment]::GetEnvironmentVariable("Path", "User")
    $standardPaths = @(
        "$env:ProgramFiles\Git\cmd",
        "$env:ProgramFiles\Git\bin",
        "$env:LOCALAPPDATA\Programs\Git\cmd",
        "$env:LOCALAPPDATA\Microsoft\WindowsApps",
        "$HOME\scoop\shims",
        "$env:LOCALAPPDATA\Programs\oh-my-posh\bin"
    )
    $all = ($machinePath, $userPath, ($standardPaths -join ';')) -join ';'
    $env:PATH = ($all -split ';' | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique) -join ';'
}

function Ensure-GitInstalled {
    Refresh-EnvironmentPath
    if (Get-Command git -ErrorAction SilentlyContinue) {
        return $true
    }

    Write-Host "[INFO] Git not found. Attempting automatic installation..." -ForegroundColor Blue

    # 1. Try Windows Package Manager (winget)
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "[INFO] Installing Git via winget..." -ForegroundColor Blue
        try {
            winget install --id Git.Git -e --source winget `
                --accept-source-agreements --accept-package-agreements `
                --disable-interactivity | Out-Null
        } catch {}
        Refresh-EnvironmentPath
        if (Get-Command git -ErrorAction SilentlyContinue) {
            Write-Host "[OK] Git installed successfully via winget." -ForegroundColor Green
            return $true
        }
    }

    # 2. Try Scoop (install Scoop if not present)
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "[INFO] Setting up Scoop package manager..." -ForegroundColor Blue
        try {
            Invoke-RestMethod -Uri https://get.scoop.io -UseBasicParsing | Invoke-Expression
            Refresh-EnvironmentPath
        } catch {}
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "[INFO] Installing Git via Scoop..." -ForegroundColor Blue
        try {
            scoop install git | Out-Null
            Refresh-EnvironmentPath
            if (Get-Command git -ErrorAction SilentlyContinue) {
                Write-Host "[OK] Git installed successfully via Scoop." -ForegroundColor Green
                return $true
            }
        } catch {}
    }

    # 3. Direct silent official installer fallback
    Write-Host "[INFO] Downloading standalone Git for Windows installer..." -ForegroundColor Blue
    try {
        $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe"
        $gitInstaller = Join-Path $env:TEMP "Git-Installer.exe"
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT", "/NORESTART", "/NOCANCEL", "/SP-", "/CLOSEAPPLICATIONS", "/RESTARTAPPLICATIONS" -Wait
        Remove-Item $gitInstaller -Force -ErrorAction SilentlyContinue
        Refresh-EnvironmentPath
        if (Get-Command git -ErrorAction SilentlyContinue) {
            Write-Host "[OK] Git installed successfully." -ForegroundColor Green
            return $true
        }
    } catch {}

    return $false
}

# Ensure Git is installed or fall back to ZIP download
$hasGit = Ensure-GitInstalled

if (Test-Path (Join-Path $DOTFILES_DIR ".git")) {
    Write-Host "[INFO] Updating existing dotfiles repository..." -ForegroundColor Blue
    if ($hasGit) {
        git -C $DOTFILES_DIR pull --ff-only
    }
} elseif ($hasGit) {
    Write-Host "[INFO] Cloning dotfiles to $DOTFILES_DIR..." -ForegroundColor Blue
    git clone $REPO_URL $DOTFILES_DIR
} else {
    Write-Host "[INFO] Downloading dotfiles archive from GitHub..." -ForegroundColor Blue
    $tempZip = Join-Path $env:TEMP "dotfiles-main.zip"
    $tempDir = Join-Path $env:TEMP "dotfiles-extract"

    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
    Invoke-WebRequest -Uri $ZIP_URL -OutFile $tempZip -UseBasicParsing
    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force

    if (-not (Test-Path $DOTFILES_DIR)) {
        New-Item -ItemType Directory -Path $DOTFILES_DIR -Force | Out-Null
    }
    Copy-Item -Path "$tempDir\dotfiles-main\*" -Destination $DOTFILES_DIR -Recurse -Force
    Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Dotfiles archive downloaded and extracted." -ForegroundColor Green
}

# Execute installer with execution policy bypass
$installer = Join-Path $DOTFILES_DIR "install.ps1"
if (Test-Path $installer) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $installer
} else {
    Write-Error "Installer script not found at $installer"
    exit 1
}

# Refresh path and activate profile in current session
Refresh-EnvironmentPath

$profilePath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Microsoft.PowerShell_profile.ps1"
if (-not (Test-Path $profilePath)) {
    $profilePath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
}

if (Test-Path $profilePath) {
    Write-Host "`n==> Activating your new shell environment..." -ForegroundColor Cyan
    . $profilePath
}

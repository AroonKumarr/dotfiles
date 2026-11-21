# Windows PowerShell Dotfiles Installer
# Aroon Kumar's Dotfiles

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

$DOTFILES_DIR = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { $PSScriptRoot }
$env:DOTFILES = $DOTFILES_DIR

# Safe backup helper
function Backup-Path {
    param([string]$Target)
    $timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
    $backupRoot = Join-Path $HOME ".dotfiles-backups\$timestamp"

    if (Test-Path -Path $Target) {
        if (-not (Test-Path -Path $backupRoot)) {
            New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
        }
        Move-Item -Path $Target -Destination $backupRoot -Force
        Write-Info "Backed up $Target to $backupRoot\"
    }
}

# Link or load profile helper
function Install-ProfileLink {
    param(
        [string]$ProfilePath,
        [string]$SourcePath
    )

    $parentDir = Split-Path -Parent $ProfilePath
    if (-not (Test-Path -Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    # If it is already pointing to our source, nothing to do
    if (Test-Path -Path $ProfilePath) {
        $content = Get-Content -Path $ProfilePath -Raw -ErrorAction SilentlyContinue
        if ($content -and $content.Contains("powershell\profile.ps1")) {
            Write-Success "$ProfilePath is already configured."
            return
        }
        Backup-Path -Target $ProfilePath
    }

    # Attempt symbolic link first
    $symlinkSuccess = $false
    try {
        New-Item -ItemType SymbolicLink -Path $ProfilePath -Target $SourcePath -Force -ErrorAction Stop | Out-Null
        $symlinkSuccess = $true
        Write-Success "Linked $ProfilePath -> $SourcePath"
    } catch {
        $symlinkSuccess = $false
    }

    # If unprivileged symlink fails (Developer Mode disabled on Windows), write safe dot-sourcing loader
    if (-not $symlinkSuccess) {
        $loaderContent = @"
# Aroon's Dotfiles - Auto-generated profile loader
`$DotfilesProfile = "$SourcePath"
if (Test-Path `$DotfilesProfile) {
    . `$DotfilesProfile
}
"@
        Set-Content -Path $ProfilePath -Value $loaderContent -Encoding UTF8 -Force
        Write-Success "Configured profile loader at $ProfilePath"
    }
}

function Ensure-BinInPath {
    Write-Header "Configuring PATH environment"
    $binDir = Join-Path $DOTFILES_DIR "bin"

    if (-not (Test-Path $binDir)) {
        return
    }

    # Update current process PATH
    if ($env:PATH -split ';' -notcontains $binDir) {
        $env:PATH = "$binDir;$env:PATH"
    }

    # Update User Environment PATH permanently
    try {
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if (-not $userPath) {
            $userPath = ""
        }

        $parts = $userPath -split ';' | Where-Object { $_ -ne "" }
        if ($parts -notcontains $binDir) {
            $newPath = ($parts + $binDir) -join ';'
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
            Write-Success "Added $binDir to User PATH."
        } else {
            Write-Success "$binDir is already in User PATH."
        }
    } catch {
        Write-Warning "Could not update User PATH in registry: $_"
    }
}

function Main {
    Write-Header "Aroon Dotfiles Installer (Windows)"

    # 1. Install CLI packages
    $windowsScript = Join-Path $DOTFILES_DIR "scripts\windows.ps1"
    if (Test-Path $windowsScript) {
        . $windowsScript
        Install-WindowsPackages
    }

    # 2. Configure PowerShell profiles for PowerShell 7 and Windows PowerShell 5.1
    Write-Header "Configuring PowerShell profiles"
    $sourceProfile = Join-Path $DOTFILES_DIR "powershell\profile.ps1"

    $docFolder = [Environment]::GetFolderPath('MyDocuments')
    $profileTargets = @(
        (Join-Path $docFolder "PowerShell\Microsoft.PowerShell_profile.ps1"),
        (Join-Path $docFolder "WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
    )

    if ($PROFILE -and ($profileTargets -notcontains $PROFILE)) {
        $profileTargets += $PROFILE
    }

    foreach ($target in $profileTargets) {
        Install-ProfileLink -ProfilePath $target -SourcePath $sourceProfile
    }

    # 3. Ensure bin directory is in PATH
    Ensure-BinInPath

    Write-Success "Installation complete!"
    Write-Host @"

Everything has been automatically configured!
- Packages installed (eza, bat, fd, ripgrep, fzf, oh-my-posh)
- MesloLGS Nerd Font installed and configured in Windows Terminal
- PowerShell profiles linked and ready

Reload your profile or open a new terminal tab:
   . `$PROFILE

"@ -ForegroundColor Cyan
}

Main

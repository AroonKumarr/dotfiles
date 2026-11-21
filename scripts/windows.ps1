# Windows package installation helper for PowerShell

function Install-WindowsPackages {
    Write-Header "Installing Windows packages"

    $packagesInstalled = $false

    # 1. Primary: Windows Package Manager (winget)
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "Found winget (Windows Package Manager)."

        $wingetPackages = @(
            @{ Id = "JanDeDobbeleer.OhMyPosh"; Name = "Oh My Posh" },
            @{ Id = "eza-community.eza";       Name = "eza" },
            @{ Id = "sharkdp.bat";              Name = "bat" },
            @{ Id = "sharkdp.fd";               Name = "fd" },
            @{ Id = "BurntSushi.ripgrep.MSVC";  Name = "ripgrep" },
            @{ Id = "junegunn.fzf";             Name = "fzf" },
            @{ Id = "Git.Git";                  Name = "Git" }
        )

        foreach ($pkg in $wingetPackages) {
            Write-Info "Ensuring $($pkg.Name) is installed..."
            try {
                winget install --id $pkg.Id -e --source winget `
                    --accept-source-agreements --accept-package-agreements `
                    --disable-interactivity | Out-Null
            } catch {
                Write-Warning "winget had an issue installing $($pkg.Name); continuing."
            }
        }
        $packagesInstalled = $true
    }
    # 2. Secondary: Scoop
    elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Info "winget not found, using Scoop package manager."
        $scoopPackages = @("git", "eza", "bat", "fd", "ripgrep", "fzf", "oh-my-posh")
        foreach ($pkg in $scoopPackages) {
            Write-Info "Ensuring $pkg is installed via Scoop..."
            scoop install $pkg | Out-Null
        }
        $packagesInstalled = $true
    }
    # 3. Tertiary: Chocolatey
    elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Info "Using Chocolatey package manager."
        choco install git eza bat fd ripgrep fzf oh-my-posh -y | Out-Null
        $packagesInstalled = $true
    }
    else {
        Write-Warning "No supported package manager found (winget, scoop, or choco)."
        Write-Warning "Install winget from Microsoft Store (App Installer), or install Scoop from https://scoop.sh"
    }

    # Install MesloLGS Nerd Font using Oh My Posh
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        Write-Info "Installing MesloLGS Nerd Font via Oh My Posh..."
        try {
            oh-my-posh font install meslo
            Write-Success "MesloLGS Nerd Font installed."
        } catch {
            Write-Warning "Could not install font automatically. Install a Nerd Font manually if icons are missing."
        }
    } else {
        Write-Warning "Oh My Posh command not yet available in current session. Font install skipped."
    }

    # Ensure PSReadLine is updated
    try {
        if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
            Write-Info "Installing PSReadLine module for syntax highlighting & history..."
            Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber -ErrorAction SilentlyContinue
        }
    } catch {
        # Non-fatal if PSReadLine installation cannot connect to PSGallery
    }
}

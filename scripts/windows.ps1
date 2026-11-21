# Windows package and font helper for PowerShell
# Aroon Kumar's Dotfiles

function Install-MesloFont {
    Write-Header "Installing MesloLGS Nerd Font"

    $fontsFolder = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
    if (-not (Test-Path $fontsFolder)) {
        New-Item -ItemType Directory -Path $fontsFolder -Force | Out-Null
    }

    $fonts = @(
        @{
            Name = "MesloLGS NF Regular (TrueType)"
            File = "MesloLGS NF Regular.ttf"
            Url  = "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
        },
        @{
            Name = "MesloLGS NF Bold (TrueType)"
            File = "MesloLGS NF Bold.ttf"
            Url  = "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
        },
        @{
            Name = "MesloLGS NF Italic (TrueType)"
            File = "MesloLGS NF Italic.ttf"
            Url  = "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
        },
        @{
            Name = "MesloLGS NF Bold Italic (TrueType)"
            File = "MesloLGS NF Bold Italic.ttf"
            Url  = "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
        }
    )

    $installedAny = $false
    $fontRegPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

    foreach ($f in $fonts) {
        $dest = Join-Path $fontsFolder $f.File
        if (-not (Test-Path $dest)) {
            Write-Info "Downloading $($f.File)..."
            try {
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                Invoke-WebRequest -Uri $f.Url -OutFile $dest -UseBasicParsing -ErrorAction Stop
                $installedAny = $true
            } catch {
                Write-Warning "Could not download $($f.File): $_"
                continue
            }
        }

        # Register in Windows registry for current user
        try {
            New-ItemProperty -Path $fontRegPath -Name $f.Name -Value $dest -PropertyType String -Force -ErrorAction SilentlyContinue | Out-Null
            $installedAny = $true
        } catch {}
    }

    # Notify Windows of font update
    if ($installedAny) {
        try {
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class FontManager {
    [DllImport("gdi32.dll", EntryPoint="AddFontResourceW", SetLastError=true)]
    public static extern int AddFontResource([MarshalAs(UnmanagedType.LPWStr)] string lpFileName);
    [DllImport("user32.dll", SetLastError=true)]
    public static extern int SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
}
"@ -ErrorAction SilentlyContinue

            foreach ($f in $fonts) {
                $target = Join-Path $fontsFolder $f.File
                if (Test-Path $target) {
                    [FontManager]::AddFontResource($target) | Out-Null
                }
            }
            [FontManager]::SendMessage([IntPtr]0xffff, 0x001D, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
        } catch {}

        Write-Success "MesloLGS Nerd Font installed successfully."
    } else {
        Write-Success "MesloLGS Nerd Font is already installed."
    }
}

function Configure-WindowsTerminalFont {
    Write-Header "Configuring Windows Terminal"

    $settingsPaths = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    )

    $configured = $false

    foreach ($settingsFile in $settingsPaths) {
        if (Test-Path $settingsFile) {
            try {
                $raw = Get-Content -Path $settingsFile -Raw -Encoding UTF8 -ErrorAction Stop
                # Strip single-line comments for JSON parsing
                $clean = $raw -replace '(?m)^\s*//.*$', ''

                $config = $clean | ConvertFrom-Json
                if (-not $config.profiles) {
                    $config | Add-Member -MemberType NoteProperty -Name "profiles" -Value ([pscustomobject]@{})
                }
                if (-not $config.profiles.defaults) {
                    $config.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value ([pscustomobject]@{})
                }
                if (-not $config.profiles.defaults.font) {
                    $config.profiles.defaults | Add-Member -MemberType NoteProperty -Name "font" -Value ([pscustomobject]@{})
                }

                $config.profiles.defaults.font | Add-Member -MemberType NoteProperty -Name "face" -Value "MesloLGS NF" -Force

                $output = $config | ConvertTo-Json -Depth 32
                Set-Content -Path $settingsFile -Value $output -Encoding UTF8 -Force
                Write-Success "Configured MesloLGS NF font in Windows Terminal: $(Split-Path -Parent $settingsFile)"
                $configured = $true
            } catch {
                Write-Warning "Could not update Windows Terminal settings file automatically: $_"
            }
        }
    }

    if (-not $configured) {
        Write-Info "Windows Terminal settings file not found yet; font will be ready once terminal is opened."
    }
}

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

    # Install Font automatically
    Install-MesloFont

    # Automatically set Windows Terminal font
    Configure-WindowsTerminalFont

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

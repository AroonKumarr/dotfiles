# PowerShell Profile - Aroon's Dotfiles

# Ensure UTF-8 output encoding for proper Nerd Font icon and Unicode rendering
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

# Resolve Dotfiles directory
if (-not $env:DOTFILES) {
    $env:DOTFILES = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

# Add personal and package manager executable directories to PATH
$candidatePaths = @(
    (Join-Path $env:DOTFILES "bin"),
    (Join-Path $HOME ".local\bin"),
    "$env:LOCALAPPDATA\Programs\oh-my-posh\bin",
    "$env:LOCALAPPDATA\Microsoft\WindowsApps",
    "$HOME\scoop\shims",
    "$env:ProgramFiles\Git\cmd",
    "$env:LOCALAPPDATA\Programs\Git\cmd"
)
foreach ($p in $candidatePaths) {
    if ((Test-Path $p) -and ($env:PATH -split ';' -notcontains $p)) {
        $env:PATH = "$p;$env:PATH"
    }
}

# Configure Oh My Posh prompt (matching Powerlevel10k theme)
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $ompTheme = Join-Path $env:DOTFILES "powershell\p10k.omp.json"
    if (Test-Path $ompTheme) {
        oh-my-posh init pwsh --config $ompTheme | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
} else {
    Write-Host "[WARN] Oh My Posh is missing. Run: $env:DOTFILES\install.ps1" -ForegroundColor Yellow
}

# Configure PSReadLine (matching zsh-autosuggestions & zsh-syntax-highlighting)
if (Get-Module -ListAvailable -Name PSReadLine) {
    try {
        Import-Module PSReadLine -ErrorAction Stop
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle InlineView
        Set-PSReadLineOption -EditMode Windows
        Set-PSReadLineOption -Colors @{
            InlinePrediction = [ConsoleColor]::DarkGray
        }
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Set-PSReadLineKeyHandler -Key Tab -Function Complete
    } catch {
        # Fallback if older PSReadLine version
    }
}

# Load aliases, functions, and OS-specific scripts
$aliasesFile = Join-Path $env:DOTFILES "powershell\aliases.ps1"
if (Test-Path $aliasesFile) { . $aliasesFile }

$functionsFile = Join-Path $env:DOTFILES "powershell\functions.ps1"
if (Test-Path $functionsFile) { . $functionsFile }

$windowsOsFile = Join-Path $env:DOTFILES "os\windows.ps1"
if (Test-Path $windowsOsFile) { . $windowsOsFile }

# fzf shell integration
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    try {
        Invoke-Expression (& fzf --powershell 2>$null)
    } catch {
        # Older fzf without --powershell flag
    }
}

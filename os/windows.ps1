# Windows-specific PowerShell helpers

# Open file or folder in default application
if (-not (Get-Command open -ErrorAction SilentlyContinue)) {
    function open {
        param([string]$Path = ".")
        Invoke-Item $Path
    }
}

# Open in Windows Explorer
if (-not (Get-Command explorer -ErrorAction SilentlyContinue)) {
    function explorer {
        param([string]$Path = ".")
        explorer.exe $Path
    }
}

# Quick clipboard copy helper
if (-not (Get-Command clip -ErrorAction SilentlyContinue)) {
    function clip {
        $input | Set-Clipboard
    }
}

# Parity with Debian/Ubuntu fdfind command
if (Get-Command fd -ErrorAction SilentlyContinue -and -not (Get-Command fdfind -ErrorAction SilentlyContinue)) {
    function fdfind { fd @args }
}

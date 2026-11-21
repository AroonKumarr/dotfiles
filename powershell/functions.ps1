# Create a directory and enter it.
function mkcd {
    <#
    .SYNOPSIS
    Create a directory and enter it.
    #>
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        Write-Warning "Usage: mkcd <directory>"
        return
    }

    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location -Path $Path
}

# Extract common archive formats.
function extract {
    <#
    .SYNOPSIS
    Extract common archive formats (.tar.gz, .tgz, .tar.bz2, .tbz2, .tar.xz, .zip, .7z, .gz, .tar).
    #>
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Archive
    )

    if (-not (Test-Path -Path $Archive -PathType Leaf)) {
        Write-Warning "Usage: extract <archive-file>"
        return
    }

    $fullPath = (Resolve-Path $Archive).Path
    $fileName = [System.IO.Path]::GetFileName($fullPath).ToLower()
    $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()

    if ($fileName -like "*.tar.gz" -or $fileName -like "*.tgz") {
        tar -xzf $fullPath
    } elseif ($fileName -like "*.tar.bz2" -or $fileName -like "*.tbz2") {
        tar -xjf $fullPath
    } elseif ($fileName -like "*.tar.xz") {
        tar -xJf $fullPath
    } elseif ($ext -eq ".tar") {
        tar -xf $fullPath
    } elseif ($ext -eq ".zip") {
        Expand-Archive -Path $fullPath -DestinationPath . -Force
    } elseif ($ext -eq ".7z") {
        if (Get-Command 7z -ErrorAction SilentlyContinue) {
            7z x $fullPath
        } else {
            Write-Warning "7z executable is required to extract .7z archives."
        }
    } elseif ($ext -eq ".gz") {
        if (Get-Command gzip -ErrorAction SilentlyContinue) {
            gzip -d $fullPath
        } else {
            tar -xzf $fullPath
        }
    } elseif ($ext -eq ".bz2") {
        if (Get-Command bunzip2 -ErrorAction SilentlyContinue) {
            bunzip2 $fullPath
        } else {
            tar -xjf $fullPath
        }
    } else {
        Write-Warning "Unsupported archive format: $Archive"
    }
}

# Run dotfiles updater
function update-dotfiles {
    <#
    .SYNOPSIS
    Update dotfiles repository and re-run installer.
    #>
    $dotfilesDir = if ($env:DOTFILES) { $env:DOTFILES } else { Join-Path $HOME ".dotfiles" }
    $updater = Join-Path $dotfilesDir "bin\update-dotfiles.ps1"
    if (Test-Path $updater) {
        & $updater
    } else {
        Write-Warning "Update script not found at $updater"
    }
}

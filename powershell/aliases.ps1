# Directory listings (modern eza integration)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    if (Test-Path Alias:ls) { Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue }
    function ls { eza @args }
    function l { eza -lah @args }
    function ll { eza -lah @args }
    function la { eza -a @args }
    function lt { eza --tree --level=2 @args }
}

# Modern cat with bat
if (Get-Command bat -ErrorAction SilentlyContinue) {
    if (Test-Path Alias:cat) { Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue }
    function cat { bat --paging=never @args }
}

# Git shortcuts (overriding PowerShell default aliases for gc, gp, gl)
if (Test-Path Alias:gs) { Remove-Item Alias:gs -Force -ErrorAction SilentlyContinue }
function gs { git status @args }

if (Test-Path Alias:ga) { Remove-Item Alias:ga -Force -ErrorAction SilentlyContinue }
function ga { git add @args }

if (Test-Path Alias:gc) { Remove-Item Alias:gc -Force -ErrorAction SilentlyContinue }
function gc { git commit @args }

if (Test-Path Alias:gp) { Remove-Item Alias:gp -Force -ErrorAction SilentlyContinue }
function gp { git push @args }

if (Test-Path Alias:gl) { Remove-Item Alias:gl -Force -ErrorAction SilentlyContinue }
function gl { git log --oneline --graph --decorate @args }

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function dotfiles {
    $target = if ($env:DOTFILES) { $env:DOTFILES } else { Join-Path $HOME ".dotfiles" }
    Set-Location $target
}

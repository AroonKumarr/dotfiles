@echo off
rem Aroon Kumar's Dotfiles - Windows Updater Wrapper
where pwsh >nul 2>&1
if %errorlevel% equ 0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-dotfiles.ps1" %*
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-dotfiles.ps1" %*
)

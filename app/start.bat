@echo off
rem Fallback launcher: use this only if scrcpy-wireless.exe (one folder up)
rem is blocked by antivirus or company policy. It opens the same window.
cd /d "%~dp0"
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0scrcpy-gui.ps1"
exit /b 0

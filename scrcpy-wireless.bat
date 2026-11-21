@echo off
rem scrcpy Wireless Kit - the only file you need to run.
rem Opens the launcher: pick devices, set window size, start mirroring,
rem and set up the Explorer "Send to" menu (button at the top).
cd /d "%~dp0"
if not exist "%~dp0adb.exe" (
  echo adb.exe / scrcpy.exe not found.
  echo Put these files in the extracted scrcpy win64 folder.
  pause
  exit /b 1
)
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0scrcpy-gui.ps1"
exit /b 0

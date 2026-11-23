# Builds the ready-to-use release zip:
#
#   scrcpy-wireless-kit-v<ver>-win64\
#     scrcpy-wireless.exe        <- the only file at the top (has the icon)
#     app\                       <- scrcpy 4.x win64 files + kit scripts + docs
#
#   powershell -ExecutionPolicy Bypass -File launcher\build.ps1 -ScrcpyDir <extracted scrcpy win64 folder> [-Version 1.1.0] [-OutDir dist]

param(
    [Parameter(Mandatory = $true)][string]$ScrcpyDir,
    [string]$Version = '1.1.0',
    [string]$OutDir  = ''
)
$ErrorActionPreference = 'Stop'
# $PSScriptRoot is empty inside param() defaults on PowerShell 5.1, so the
# default output folder is resolved here instead.
$repo = Split-Path $PSScriptRoot -Parent
if (-not $OutDir) { $OutDir = Join-Path $repo 'dist' }
$name = "scrcpy-wireless-kit-v$Version-win64"
$stage = Join-Path $OutDir $name
$app = Join-Path $stage 'app'

if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
New-Item -ItemType Directory -Force $app | Out-Null

# 1. Launcher exe with the icon.
$csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path $csc)) { $csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe' }
& $csc /nologo /target:winexe /platform:anycpu /optimize+ `
    "/win32icon:$(Join-Path $PSScriptRoot 'app.ico')" `
    "/out:$(Join-Path $stage 'scrcpy-wireless.exe')" `
    /r:System.Windows.Forms.dll (Join-Path $PSScriptRoot 'Launcher.cs')
if ($LASTEXITCODE -ne 0) { throw 'csc failed' }

# 2. scrcpy release files (unmodified).
$scrcpyFiles = 'adb.exe','AdbWinApi.dll','AdbWinUsbApi.dll','avcodec-*.dll','avformat-*.dll','avutil-*.dll',
               'swresample-*.dll','SDL*.dll','libusb-1.0.dll','scrcpy.exe','scrcpy-server','scrcpy-noconsole.vbs',
               'open_a_terminal_here.bat','scrcpy.png','disconnected.png','LICENSE.txt'
foreach ($pat in $scrcpyFiles) {
    $hits = @(Get-ChildItem -Path $ScrcpyDir -Filter $pat -File)
    if ($hits.Count -eq 0) { throw "missing in scrcpy folder: $pat" }
    $hits | Copy-Item -Destination $app
}

# 3. Kit files.
Copy-Item (Join-Path $repo 'app\*') $app -Recurse
Copy-Item (Join-Path $PSScriptRoot 'app.ico') $app
Copy-Item (Join-Path $repo 'README.md') $app
Copy-Item (Join-Path $repo 'LICENSE') (Join-Path $app 'LICENSE-scrcpy-wireless-kit.txt')
Copy-Item (Join-Path $PSScriptRoot 'THIRD_PARTY_NOTICES.txt') $app
New-Item -ItemType Directory -Force (Join-Path $app 'docs') | Out-Null
Copy-Item (Join-Path $repo 'docs\*') (Join-Path $app 'docs')

# 4. Zip.
$zip = Join-Path $OutDir "$name.zip"
if (Test-Path $zip) { Remove-Item $zip }
Compress-Archive -Path $stage -DestinationPath $zip
"Built $zip ($([math]::Round((Get-Item $zip).Length / 1MB, 1)) MB)"

# Explorer "Send to" menu setup - opened from the launcher's "보내기 메뉴 설정" button.
# Adds one "Send to <name>" entry per wireless device that is currently online
# (found via mDNS), or removes them all. Entries call send-to-device.ps1 with
# the device's hardware serial, so they keep working when the IP/port changes.
# Saved as UTF-8 with BOM - reapply BOM after editing.

param([switch]$Uninstall)

$AdbExe  = Join-Path $PSScriptRoot 'adb.exe'
$SendPs1 = Join-Path $PSScriptRoot 'send-to-device.ps1'
$SendTo  = [Environment]::GetFolderPath('SendTo')
$PsExe   = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$env:ADB_MDNS_OPENSCREEN = '1'
$Shell   = New-Object -ComObject WScript.Shell
$Host.UI.RawUI.WindowTitle = '보내기 메뉴 설정 / Send-to menu setup'

function Invoke-Adb { param([string[]]$A) & $AdbExe @A 2>$null }

function Finish([int]$code) {
    Write-Host ''
    Read-Host 'Enter를 누르면 닫힙니다 / Press Enter to close' | Out-Null
    exit $code
}

# Shortcuts in SendTo that point at THIS folder's send script (other copies'
# shortcuts are left alone).
function Get-OurShortcuts {
    @(Get-ChildItem -LiteralPath $SendTo -Filter '*.lnk' -ErrorAction SilentlyContinue |
        Where-Object { $Shell.CreateShortcut($_.FullName).Arguments.Contains("`"$SendPs1`"") })
}

$existing = Get-OurShortcuts
if (-not $Uninstall) {
    Write-Host '보내기 메뉴 설정 / Send-to menu setup' -ForegroundColor Cyan
    if ($existing.Count -gt 0) {
        Write-Host ('현재 등록됨 / Installed: ' + (($existing | ForEach-Object BaseName) -join ', '))
    }
    Write-Host '  1) 기기 메뉴 추가/갱신  Add / update entries for connected devices'
    Write-Host '  2) 모두 제거            Remove all entries'
    $choice = Read-Host '선택 / Choose [1]'
    if ($choice -eq '2') { $Uninstall = $true }
}

if ($Uninstall) {
    foreach ($l in $existing) { Remove-Item -LiteralPath $l.FullName; Write-Host "제거 / Removed: $($l.BaseName)" }
    Write-Host "$($existing.Count)개 제거 / removed."
    Finish 0
}

if (-not (Test-Path $AdbExe)) {
    Write-Host 'adb.exe가 없습니다. 이 파일들을 scrcpy 폴더에 넣어 주세요. / adb.exe not found - put these files in the scrcpy folder.' -ForegroundColor Red
    Finish 1
}

Write-Host ''
Write-Host '기기 찾는 중... / Searching for devices...' -ForegroundColor Cyan
Invoke-Adb @('start-server') | Out-Null

function Get-MdnsAddrs {
    foreach ($line in @(Invoke-Adb @('mdns', 'services'))) {
        if ("$line" -match '_adb-tls-connect\._tcp\s+(\S+:\d+)') { $Matches[1] }
    }
}
$addrs = @(Get-MdnsAddrs)
if ($addrs.Count -eq 0 -and @(Get-Process scrcpy -ErrorAction SilentlyContinue).Count -eq 0) {
    # A long-running adb server can miss mDNS announcements; restart it.
    Invoke-Adb @('kill-server') | Out-Null
    Invoke-Adb @('start-server') | Out-Null
    for ($i = 0; $i -lt 8 -and $addrs.Count -eq 0; $i++) { Start-Sleep 1; $addrs = @(Get-MdnsAddrs) }
}
foreach ($a in $addrs) { Invoke-Adb @('connect', $a) | Out-Null }

# Online devices, deduplicated by hardware serial.
$devices = [ordered]@{}
foreach ($line in @(Invoke-Adb @('devices'))) {
    if ("$line" -notmatch '^(\S+)\s+device$') { continue }
    $t = $Matches[1]
    $info = @(Invoke-Adb @('-s', $t, 'shell', 'getprop ro.serialno; getprop ro.product.model'))
    $serial = if ($info.Count -gt 0) { "$($info[0])".Trim() } else { '' }
    $model  = if ($info.Count -gt 1) { "$($info[1])".Trim() } else { $serial }
    if ($serial -and -not $devices.Contains($serial)) { $devices[$serial] = $model }
}

if ($devices.Count -eq 0) {
    Write-Host '기기를 찾지 못했습니다. 기기에서 개발자 옵션 → 무선 디버깅을 켜 주세요(처음이면 페어링 먼저).' -ForegroundColor Red
    Write-Host 'No device found. Turn ON Developer options > Wireless debugging (pair it once first).' -ForegroundColor Red
    Finish 1
}

foreach ($serial in $devices.Keys) {
    $model = $devices[$serial]
    $name = Read-Host "$model ($serial) 메뉴 이름 / menu name [Enter = $model, - = skip]"
    if ($name -eq '-') { continue }
    if (-not $name) { $name = $model }
    $safe = ($name -replace '[\\/:*?"<>|]', '_').Trim()

    # Replace an older entry for the same device, if any.
    Get-OurShortcuts | Where-Object { $Shell.CreateShortcut($_.FullName).Arguments.Contains("-Serial `"$serial`"") } |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName }

    $lnk = $Shell.CreateShortcut((Join-Path $SendTo "Send to $safe.lnk"))
    $lnk.TargetPath       = $PsExe
    $lnk.Arguments        = "-NoProfile -ExecutionPolicy Bypass -File `"$SendPs1`" -Serial `"$serial`" -Label `"$safe`""
    $lnk.WorkingDirectory = $PSScriptRoot
    $icon = Join-Path $PSScriptRoot 'scrcpy.exe'
    if (Test-Path $icon) { $lnk.IconLocation = "$icon,0" }
    $lnk.Save()
    Write-Host "추가 / Created: Send to $safe" -ForegroundColor Green
}

Write-Host ''
Write-Host '완료. 파일 우클릭 → 보내기 → "Send to <이름>"  (Windows 11: 추가 옵션 표시)'
Write-Host 'Done. Right-click a file > Send to > "Send to <name>"  (Windows 11: Show more options)'
Finish 0

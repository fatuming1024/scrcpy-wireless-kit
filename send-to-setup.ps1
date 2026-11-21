# Explorer "Send to" menu setup - opened from the launcher's send-to button.
# Adds one entry per wireless device that is currently online (found via mDNS),
# or removes them all. Entries call send-to-device.ps1 with the device's
# hardware serial, so they keep working when the IP/port changes.
# Text: Korean on Korean Windows, English otherwise (override: SCRCPY_LANG=ko|en).
# Saved as UTF-8 with BOM - reapply BOM after editing.

param([switch]$Uninstall)

$AdbExe  = Join-Path $PSScriptRoot 'adb.exe'
$SendPs1 = Join-Path $PSScriptRoot 'send-to-device.ps1'
$SendTo  = [Environment]::GetFolderPath('SendTo')
$PsExe   = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$env:ADB_MDNS_OPENSCREEN = '1'
$Shell   = New-Object -ComObject WScript.Shell

$LangCode = if ($env:SCRCPY_LANG) { $env:SCRCPY_LANG } else { (Get-UICulture).TwoLetterISOLanguageName }
$IsKo = $LangCode -eq 'ko'
function L([string]$ko, [string]$en) { if ($IsKo) { $ko } else { $en } }

$Host.UI.RawUI.WindowTitle = (L '보내기 메뉴 설정' 'Send-to menu setup')

function Invoke-Adb { param([string[]]$A) & $AdbExe @A 2>$null }

function Finish([int]$code) {
    Write-Host ''
    Read-Host (L 'Enter를 누르면 닫힙니다' 'Press Enter to close') | Out-Null
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
    Write-Host (L '보내기 메뉴 설정' 'Send-to menu setup') -ForegroundColor Cyan
    if ($existing.Count -gt 0) {
        Write-Host ((L '현재 등록됨: ' 'Installed: ') + (($existing | ForEach-Object BaseName) -join ', '))
    }
    Write-Host (L '  1) 연결된 기기의 메뉴 추가/갱신' '  1) Add / update entries for connected devices')
    Write-Host (L '  2) 모두 제거' '  2) Remove all entries')
    $choice = Read-Host (L '선택 [1]' 'Choose [1]')
    if ($choice -eq '2') { $Uninstall = $true }
}

if ($Uninstall) {
    foreach ($l in $existing) { Remove-Item -LiteralPath $l.FullName; Write-Host ((L '제거: ' 'Removed: ') + $l.BaseName) }
    Write-Host ((L '{0}개 제거했습니다.' '{0} entry(s) removed.') -f $existing.Count)
    Finish 0
}

if (-not (Test-Path $AdbExe)) {
    Write-Host (L 'adb.exe가 없습니다. 이 파일들을 scrcpy 폴더에 넣어 주세요.' 'adb.exe not found - put these files in the scrcpy folder.') -ForegroundColor Red
    Finish 1
}

Write-Host ''
Write-Host (L '기기 찾는 중...' 'Searching for devices...') -ForegroundColor Cyan
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
    Write-Host (L '기기를 찾지 못했습니다. 기기에서 개발자 옵션 → 무선 디버깅을 켜 주세요(처음이면 페어링 먼저).' `
                  'No device found. Turn ON Developer options > Wireless debugging on the device (pair it once first).') -ForegroundColor Red
    Finish 1
}

foreach ($serial in $devices.Keys) {
    $model = $devices[$serial]
    $name = Read-Host ((L '{0} ({1}) 메뉴 이름 [Enter = {0}, - = 건너뛰기]' '{0} ({1}) menu name [Enter = {0}, - = skip]') -f $model, $serial)
    if ($name -eq '-') { continue }
    if (-not $name) { $name = $model }
    $safe = ($name -replace '[\\/:*?"<>|]', '_').Trim()
    $menu = (L '{0}에 보내기' 'Send to {0}') -f $safe

    # Replace an older entry for the same device, if any.
    Get-OurShortcuts | Where-Object { $Shell.CreateShortcut($_.FullName).Arguments.Contains("-Serial `"$serial`"") } |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName }

    $lnk = $Shell.CreateShortcut((Join-Path $SendTo "$menu.lnk"))
    $lnk.TargetPath       = $PsExe
    $lnk.Arguments        = "-NoProfile -ExecutionPolicy Bypass -File `"$SendPs1`" -Serial `"$serial`" -Label `"$safe`""
    $lnk.WorkingDirectory = $PSScriptRoot
    $icon = Join-Path $PSScriptRoot 'scrcpy.exe'
    if (Test-Path $icon) { $lnk.IconLocation = "$icon,0" }
    $lnk.Save()
    Write-Host ((L '추가: ' 'Created: ') + $menu) -ForegroundColor Green
}

Write-Host ''
Write-Host (L '완료. 파일 우클릭 → 보내기에서 고르세요. (Windows 11: 먼저 "추가 옵션 표시")' `
              'Done. Right-click a file > Send to. (Windows 11: "Show more options" first)')
Finish 0

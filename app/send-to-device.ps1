# Push files/folders (passed as arguments, e.g. from Explorer's "Send to" menu)
# to a device's Download folder over wireless debugging.
#   -Serial  hardware serial (ro.serialno) of the target device  (required)
#   -Label   name shown in messages (defaults to the serial)
# The "Send to" shortcuts that call this are created by send-to-setup.ps1 (launcher button).
# Saved as UTF-8 with BOM (Korean messages) - reapply BOM after editing.

param(
    [Parameter(Mandatory = $true)][string]$Serial,
    [string]$Label = '',
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$Paths
)
if (-not $Label) { $Label = $Serial }

$Target = '/sdcard/Download/'
$AdbExe = Join-Path $PSScriptRoot 'adb.exe'
$env:ADB_MDNS_OPENSCREEN = '1'

# Messages: Korean on Korean Windows, English otherwise; the launcher's language button overrides both.
# Same order as the launcher: saved choice (language button), SCRCPY_LANG, Windows language.
$LangFile = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'scrcpy-wireless-kit\lang.txt'
$LangCode = try { "$(Get-Content -LiteralPath $LangFile -TotalCount 1 -ErrorAction Stop)".Trim() } catch { '' }
if ($LangCode -notin 'ko', 'en') { $LangCode = if ($env:SCRCPY_LANG) { $env:SCRCPY_LANG } else { (Get-UICulture).TwoLetterISOLanguageName } }
$IsKo = $LangCode -eq 'ko'
function L([string]$ko, [string]$en) { if ($IsKo) { $ko } else { $en } }

$Host.UI.RawUI.WindowTitle = (L "$Label(으)로 보내기" "Send to $Label")

function Invoke-Adb { param([string[]]$A) & $AdbExe @A 2>$null }

# Escape a string for use inside single quotes in the device shell.
function Quote-Sh([string]$s) { $s -replace "'", "'\''" }

function Stop-WithError($msg) {
    Write-Host ""
    Write-Host ((L '[실패] ' '[Failed] ') + $msg) -ForegroundColor Red
    Read-Host (L 'Enter를 누르면 닫힙니다' 'Press Enter to close') | Out-Null
    exit 1
}

# Online transport (ip:port or mDNS name) whose hardware serial is $Serial.
function Find-Online {
    $addrs = @(Invoke-Adb @('devices') | ForEach-Object {
        if ("$_" -match '^(\S+)\s+device$') { $Matches[1] } })
    # Prefer ip:port over the mDNS transport name.
    $addrs = @($addrs | Sort-Object { if ($_ -match '^\d+\.\d+\.\d+\.\d+:\d+$') { 0 } else { 1 } })
    foreach ($a in $addrs) {
        $s = "$(Invoke-Adb @('-s', $a, 'shell', 'getprop ro.serialno'))".Trim()
        if ($s -eq $Serial) { return $a }
    }
    return $null
}

function Get-MdnsAddr {
    foreach ($line in @(Invoke-Adb @('mdns', 'services'))) {
        if ("$line" -match "adb-$Serial\S*\s+_adb-tls-connect\._tcp\s+(\S+:\d+)") { return $Matches[1] }
    }
    return $null
}

if (-not $Paths -or $Paths.Count -eq 0) {
    Stop-WithError (L '보낼 파일이 없습니다. 탐색기에서 파일 우클릭 → 보내기 메뉴로 사용하세요.' `
                      'No files given. Use it from Explorer: right-click a file > Send to.')
}

Write-Host (L "$Label 찾는 중..." "Searching for $Label...") -ForegroundColor Cyan
Invoke-Adb @('start-server') | Out-Null

$addr = Find-Online
if (-not $addr) {
    $mdns = Get-MdnsAddr
    # A stale adb server can miss mDNS announcements; a fresh one queries again.
    # Do not restart while scrcpy is running - that would cut live mirroring.
    if (-not $mdns -and @(Get-Process scrcpy -ErrorAction SilentlyContinue).Count -eq 0) {
        Invoke-Adb @('kill-server') | Out-Null
        Invoke-Adb @('start-server') | Out-Null
        for ($i = 0; $i -lt 8 -and -not $mdns; $i++) {
            Start-Sleep -Milliseconds 1000
            $mdns = Get-MdnsAddr
        }
    }
    if (-not $mdns) {
        Stop-WithError (L "$Label 을(를) 찾지 못했습니다. 화면을 켜고 개발자 옵션 → 무선 디버깅을 켜 주세요." `
                          "$Label not found. Wake the device and turn on Developer options > Wireless debugging.")
    }
    Invoke-Adb @('connect', $mdns) | Out-Null
    Start-Sleep -Milliseconds 800
    $addr = Find-Online
    if (-not $addr) {
        Stop-WithError (L "$Label($mdns)에 연결하지 못했습니다. 페어링이 풀렸을 수 있습니다 - 무선 디버깅 → 페어링 코드로 기기 페어링 후 다시 시도하세요." `
                          "Could not connect to $Label ($mdns). The pairing may have been lost - pair again (Wireless debugging > Pair device with pairing code).")
    }
}

Write-Host ((L '연결됨: ' 'Connected: ') + $addr) -ForegroundColor Green
Write-Host ""

$ok = 0; $fail = @()
foreach ($p in $Paths) {
    $name = Split-Path $p -Leaf
    Write-Host "→ $name"
    if (Test-Path -LiteralPath $p -PathType Container) {
        # adb hangs when the REMOTE directory name is non-ASCII (e.g. Korean),
        # so push under an ASCII temp name and rename it on the device.
        $tmp   = $Target + '.sendto_tmp_' + [guid]::NewGuid().ToString('N').Substring(0, 8)
        $final = $Target + $name
        $n = 2
        while ("$(Invoke-Adb @('-s', $addr, 'shell', "[ -e '$(Quote-Sh $final)' ] && echo y"))".Trim() -eq 'y') {
            $final = "$Target$name ($n)"; $n++
        }
        & $AdbExe -s $addr push $p $tmp
        $code = $LASTEXITCODE
        if ($code -eq 0) {
            Invoke-Adb @('-s', $addr, 'shell', "mv '$(Quote-Sh $tmp)' '$(Quote-Sh $final)'") | Out-Null
            $code = $LASTEXITCODE
        }
    } else {
        # Always pass the full remote path: adb fails ("Is a directory") when a
        # non-ASCII file is pushed to a bare directory target.
        & $AdbExe -s $addr push $p ($Target + $name)
        $code = $LASTEXITCODE
    }
    if ($code -eq 0) { $ok++ } else { $fail += $name }
}

Write-Host ""
if ($fail.Count -gt 0) {
    Stop-WithError ((L '{0}개 성공, {1}개 실패: {2}' '{0} sent, {1} failed: {2}') -f $ok, $fail.Count, ($fail -join ', '))
}
Write-Host ((L '완료 - {0}개를 {1} Download 폴더로 보냈습니다.' 'Done - sent {0} item(s) to the Download folder on {1}.') -f $ok, $Label) -ForegroundColor Green
Start-Sleep -Seconds 3

# Push files/folders (passed as arguments, e.g. from Explorer's "Send to" menu)
# to a device's Download folder over wireless debugging.
#   -Serial  hardware serial (ro.serialno) of the target device  (required)
#   -Label   name shown in messages (defaults to the serial)
# The "Send to" shortcuts that call this are created by send-to-setup.ps1 (launcher button "보내기 메뉴 설정").
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
$Host.UI.RawUI.WindowTitle = "$Label(으)로 보내기"

function Invoke-Adb { param([string[]]$A) & $AdbExe @A 2>$null }

# Escape a string for use inside single quotes in the device shell.
function Quote-Sh([string]$s) { $s -replace "'", "'\''" }

function Stop-WithError($msg) {
    Write-Host ""
    Write-Host "[실패] $msg" -ForegroundColor Red
    Read-Host "Enter를 누르면 닫힙니다" | Out-Null
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

if (-not $Paths -or $Paths.Count -eq 0) { Stop-WithError "보낼 파일이 없습니다. 파일을 우클릭 → 보내기 → $Label(으)로 보내기로 사용하세요." }

Write-Host "$Label 찾는 중..." -ForegroundColor Cyan
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
        Stop-WithError "$Label 을(를) 찾지 못했습니다. $Label 화면을 켜고 개발자 옵션 → 무선 디버깅을 켜 주세요."
    }
    Invoke-Adb @('connect', $mdns) | Out-Null
    Start-Sleep -Milliseconds 800
    $addr = Find-Online
    if (-not $addr) {
        Stop-WithError "$Label($mdns)에 연결하지 못했습니다. 페어링이 풀렸을 수 있습니다 - 무선 디버깅 → 페어링 코드로 기기 페어링 후 다시 시도하세요."
    }
}

Write-Host "연결됨: $addr" -ForegroundColor Green
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
    Stop-WithError ("{0}개 성공, {1}개 실패: {2}" -f $ok, $fail.Count, ($fail -join ', '))
}
Write-Host ("완료 - {0}개를 {1} Download 폴더로 보냈습니다." -f $ok, $Label) -ForegroundColor Green
Start-Sleep -Seconds 3

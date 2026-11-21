#Requires -Version 5.1
# scrcpy device launcher - Toss style GUI
# Launched by scrcpy-wireless.bat

$ErrorActionPreference = 'Continue'
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml

$Root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$AdbExe = Join-Path $Root 'adb.exe'
$ScrExe = Join-Path $Root 'scrcpy.exe'
$env:ADB_MDNS_OPENSCREEN = '1'

function Invoke-Adb {
    param([string[]]$Arguments)
    try { & $AdbExe @Arguments 2>$null } catch { @() }
}

# ---------------------------------------------------------------- XAML

$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="scrcpy" Width="680" Height="670"
        WindowStartupLocation="CenterScreen" WindowStyle="None"
        AllowsTransparency="True" Background="Transparent"
        FontFamily="Pretendard, Malgun Gothic, Segoe UI"
        TextOptions.TextFormattingMode="Ideal">
  <Window.Resources>

    <Style x:Key="TossCheck" TargetType="CheckBox">
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="CheckBox">
            <Border x:Name="Bd" Width="26" Height="26" CornerRadius="8"
                    Background="White" BorderBrush="#D1D6DB" BorderThickness="2">
              <Path x:Name="Ck" Data="M 0,5 L 4.2,9.6 L 11.2,1.4" Stroke="White"
                    StrokeThickness="2.4" StrokeStartLineCap="Round"
                    StrokeEndLineCap="Round" StrokeLineJoin="Round"
                    HorizontalAlignment="Center" VerticalAlignment="Center"
                    Visibility="Collapsed"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="Bd" Property="Background" Value="#3182F6"/>
                <Setter TargetName="Bd" Property="BorderBrush" Value="#3182F6"/>
                <Setter TargetName="Ck" Property="Visibility" Value="Visible"/>
              </Trigger>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="Bd" Property="BorderBrush" Value="#3182F6"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="SegBtn" TargetType="RadioButton">
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RadioButton">
            <Border x:Name="Bd" CornerRadius="8" Background="Transparent" Padding="11,6" Margin="1,0">
              <TextBlock x:Name="Tx" Text="{TemplateBinding Content}" FontSize="12.5"
                         FontWeight="SemiBold" Foreground="#8B95A1" HorizontalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="Bd" Property="Background" Value="White"/>
                <Setter TargetName="Tx" Property="Foreground" Value="#3182F6"/>
                <Setter TargetName="Tx" Property="FontWeight" Value="Bold"/>
              </Trigger>
              <MultiTrigger>
                <MultiTrigger.Conditions>
                  <Condition Property="IsChecked" Value="False"/>
                  <Condition Property="IsMouseOver" Value="True"/>
                </MultiTrigger.Conditions>
                <Setter TargetName="Tx" Property="Foreground" Value="#4E5968"/>
              </MultiTrigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="Primary" TargetType="Button">
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Height" Value="54"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="Bd" CornerRadius="14" Background="#3182F6">
              <TextBlock Text="{TemplateBinding Content}" FontSize="16" FontWeight="Bold"
                         Foreground="White" HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="Bd" Property="Background" Value="#1B64DA"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter TargetName="Bd" Property="Background" Value="#E5E8EB"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="Secondary" TargetType="Button">
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Height" Value="54"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="Bd" CornerRadius="14" Background="#F2F4F6">
              <TextBlock Text="{TemplateBinding Content}" FontSize="15" FontWeight="Bold"
                         Foreground="#4E5968" HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="Bd" Property="Background" Value="#E5E8EB"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="Ghost" TargetType="Button">
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Height" Value="36"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="Bd" CornerRadius="10" Background="Transparent" Padding="12,0">
              <TextBlock Text="{TemplateBinding Content}" FontSize="13" FontWeight="Bold"
                         Foreground="#3182F6" HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="Bd" Property="Background" Value="#EFF6FF"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="IconBtn" TargetType="Button">
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Width" Value="34"/>
      <Setter Property="Height" Value="34"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="Bd" CornerRadius="10" Background="Transparent">
              <TextBlock Text="{TemplateBinding Content}" FontSize="15" Foreground="#8B95A1"
                         HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="Bd" Property="Background" Value="#F2F4F6"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

  </Window.Resources>

  <Border Background="White" CornerRadius="20" Margin="14">
    <Border.Effect>
      <DropShadowEffect BlurRadius="28" ShadowDepth="3" Opacity="0.13" Color="#000000"/>
    </Border.Effect>

    <Grid Margin="30,20,30,26">
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>

      <Grid x:Name="TitleBar" Grid.Row="0" Background="Transparent">
        <TextBlock Text="scrcpy" FontSize="13" FontWeight="Bold" Foreground="#B0B8C1"
                   VerticalAlignment="Center"/>
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,-4,-8,0">
          <Button x:Name="SendToBtn" Content="보내기 메뉴 설정" Style="{StaticResource Ghost}"
                  Height="34" ToolTip="탐색기 우클릭 → 보내기에 기기별 메뉴를 추가/제거합니다"/>
          <Button x:Name="CloseBtn" Content="✕" Style="{StaticResource IconBtn}"/>
        </StackPanel>
      </Grid>

      <Grid Grid.Row="1" Margin="0,14,0,18">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <StackPanel Grid.Column="0">
          <TextBlock Text="미러링할 기기를 선택하세요" FontSize="23" FontWeight="Bold" Foreground="#191F28"/>
          <TextBlock x:Name="SubText" Text="무선 디버깅이 켜진 기기를 자동으로 찾습니다"
                     FontSize="13.5" Foreground="#8B95A1" Margin="0,7,0,0"/>
        </StackPanel>
        <Button x:Name="SelectAllBtn" Grid.Column="1" Content="전체 선택"
                Style="{StaticResource Ghost}" VerticalAlignment="Bottom"
                Margin="10,0,-8,0" Visibility="Collapsed"/>
      </Grid>

      <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" Padding="0,0,4,0">
        <StackPanel x:Name="DeviceList"/>
      </ScrollViewer>

      <Border x:Name="StatusBox" Grid.Row="3" Background="#F4F6F8" CornerRadius="12"
              Padding="14,11" Margin="0,16,0,0" Visibility="Collapsed">
        <TextBlock x:Name="StatusText" Text="" FontSize="12.5" Foreground="#4E5968" TextWrapping="Wrap"/>
      </Border>

      <Grid Grid.Row="4" Margin="0,18,0,0">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="130"/>
          <ColumnDefinition Width="10"/>
          <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Button x:Name="RefreshBtn" Grid.Column="0" Content="새로고침" Style="{StaticResource Secondary}"/>
        <Button x:Name="LaunchBtn" Grid.Column="2" Content="미러링 시작" Style="{StaticResource Primary}"
                IsEnabled="False"/>
      </Grid>

    </Grid>
  </Border>
</Window>
'@

$cardXaml = @'
<Border xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Background="#FAFBFC" BorderBrush="#EDF0F3" BorderThickness="1.5"
        CornerRadius="16" Padding="16,14" Margin="0,0,0,10">
  <Grid>
    <Grid.ColumnDefinitions>
      <ColumnDefinition Width="Auto"/>
      <ColumnDefinition Width="*"/>
      <ColumnDefinition Width="Auto"/>
    </Grid.ColumnDefinitions>

    <CheckBox Tag="chk" Style="{DynamicResource TossCheck}" IsChecked="False"
              VerticalAlignment="Center" Margin="0,0,15,0"/>

    <StackPanel Grid.Column="1" VerticalAlignment="Center">
      <TextBlock Text="__NAME__" FontSize="15.5" FontWeight="Bold" Foreground="#191F28"
                 TextTrimming="CharacterEllipsis"/>
      <TextBlock Text="__SUB__" FontSize="11.5" Foreground="#8B95A1" Margin="0,4,0,0"
                 TextTrimming="CharacterEllipsis"/>
    </StackPanel>

    <StackPanel Grid.Column="2" VerticalAlignment="Center" Margin="12,0,0,0">
      <Border Background="#F2F4F6" CornerRadius="10" Padding="3">
        <StackPanel Orientation="Horizontal">
          <RadioButton GroupName="__G__" Tag="pct:30"  Content="30%"  Style="{DynamicResource SegBtn}"/>
          <RadioButton GroupName="__G__" Tag="pct:50"  Content="50%"  Style="{DynamicResource SegBtn}" IsChecked="True"/>
          <RadioButton GroupName="__G__" Tag="pct:75"  Content="75%"  Style="{DynamicResource SegBtn}"/>
          <RadioButton GroupName="__G__" Tag="pct:100" Content="100%" Style="{DynamicResource SegBtn}"/>
        </StackPanel>
      </Border>
      <TextBlock Tag="px" Text="" FontSize="11" Foreground="#B0B8C1"
                 HorizontalAlignment="Right" Margin="0,6,3,0"/>
    </StackPanel>
  </Grid>
</Border>
'@

$emptyXaml = @'
<TextBlock xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
           FontSize="13.5" Foreground="#8B95A1" TextAlignment="Center"
           LineHeight="25" Margin="0,54,0,54">연결된 기기가 없습니다.<LineBreak/><LineBreak/>기기에서 개발자 옵션 &gt; 무선 디버깅을 켠 뒤<LineBreak/>새로고침을 눌러주세요.</TextBlock>
'@

$win = [Windows.Markup.XamlReader]::Parse($xaml)

$DeviceList = $win.FindName('DeviceList')
$StatusBox  = $win.FindName('StatusBox')
$StatusText = $win.FindName('StatusText')
$SubText    = $win.FindName('SubText')
$LaunchBtn  = $win.FindName('LaunchBtn')
$RefreshBtn = $win.FindName('RefreshBtn')
$SelectAllBtn = $win.FindName('SelectAllBtn')
$CloseBtn   = $win.FindName('CloseBtn')
$SendToBtn  = $win.FindName('SendToBtn')
$TitleBar   = $win.FindName('TitleBar')

# ---------------------------------------------------------------- helpers

function Get-Descendants {
    param($Element)
    $queue = New-Object System.Collections.Queue
    $queue.Enqueue($Element)
    while ($queue.Count -gt 0) {
        $node = $queue.Dequeue()
        $node
        foreach ($child in [Windows.LogicalTreeHelper]::GetChildren($node)) {
            if ($child -is [Windows.DependencyObject]) { $queue.Enqueue($child) }
        }
    }
}

function Set-Status {
    param([string]$Message)
    if ([string]::IsNullOrWhiteSpace($Message)) {
        $StatusBox.Visibility = 'Collapsed'
    } else {
        $StatusText.Text = $Message
        $StatusBox.Visibility = 'Visible'
    }
}

# Flush one render pass. This pumps a nested message loop, so only call it
# from a blocking operation the user is waiting on - never from a click
# handler, where the re-entry would let the handler fire twice.
function Sync-Ui {
    $win.Dispatcher.Invoke([Action] {}, [Windows.Threading.DispatcherPriority]::Render) | Out-Null
}

# The percentage sets the WINDOW size, not the stream resolution. scrcpy fixes
# the encoded resolution when it starts, so a stream capped to a small size
# stays blurry no matter how large the window is dragged afterwards. Keeping
# the stream at $StreamMaxSize and only shrinking the window means the picture
# stays sharp when the user enlarges it later.
$StreamMaxSize   = 1920   # longest edge of the encoded video
$FallbackMaxSize = 1024   # software encoder can't keep up with more

function Get-WindowSize {
    param([int]$Width, [int]$Height, [int]$Percent)

    $longest = [Math]::Max($Width, $Height)

    # Never open a window bigger than the desktop work area. The limit is the
    # smaller edge of the work area so the box still fits if the device is
    # turned the other way round.
    $area  = [Windows.SystemParameters]::WorkArea
    $limit = [Math]::Min($area.Width - 80, $area.Height - 80)
    if ($limit -lt 240) { $limit = 240.0 }

    $side = [Math]::Min($longest * $Percent / 100.0, $limit)
    if ($side -lt 200) { $side = 200.0 }

    # scrcpy fits the video inside the --window-width/--window-height box while
    # preserving the aspect ratio, so a SQUARE box makes the long edge of the
    # window land on $side whichever way the device is currently rotated.
    # Width/Height below are only what that works out to right now, for display.
    if ($Width -ge $Height) {
        $w = $side; $h = $side * $Height / $Width
    } else {
        $h = $side; $w = $side * $Width / $Height
    }

    [pscustomobject]@{
        Box    = [int][Math]::Round($side)
        Width  = [int][Math]::Round($w)
        Height = [int][Math]::Round($h)
    }
}

# ip:port of every wireless-debugging service adb's mDNS currently sees.
function Get-MdnsAddrs {
    foreach ($line in @(Invoke-Adb @('mdns', 'services'))) {
        if ("$line" -match '_adb-tls-connect\._tcp\s+(\S+:\d+)') { $Matches[1] }
    }
}

# Devices reachable over adb, deduplicated by hardware serial.
function Get-DeviceList {
    Invoke-Adb @('start-server') | Out-Null

    $services = @(Get-MdnsAddrs)

    # A long-running adb server stops seeing mDNS announcements (Windows
    # firewall drops unsolicited multicast to this adb.exe); only replies to
    # the queries a fresh server sends at startup get through. So when
    # nothing is listed, restart the server and poll for a few seconds.
    # Never restart while a device is online or scrcpy is running: killing
    # the server would drop those live connections.
    $online  = @(Invoke-Adb @('devices') | Where-Object { "$_" -match '\sdevice$' }).Count
    $running = @(Get-Process scrcpy -ErrorAction SilentlyContinue).Count
    if ($services.Count -eq 0 -and $online -eq 0 -and $running -eq 0) {
        Invoke-Adb @('kill-server') | Out-Null
        Invoke-Adb @('start-server') | Out-Null
        for ($i = 0; $i -lt 8 -and $services.Count -eq 0; $i++) {
            Start-Sleep -Milliseconds 1000
            $services = @(Get-MdnsAddrs)
        }
    }

    foreach ($addr in $services) {
        Invoke-Adb @('connect', $addr) | Out-Null
    }

    $found = @{}
    $order = New-Object System.Collections.ArrayList

    foreach ($line in @(Invoke-Adb @('devices'))) {
        if ("$line" -notmatch '^(\S+)\s+device$') { continue }
        $addr = $Matches[1]

        $props = @(Invoke-Adb @('-s', $addr, 'shell',
            "getprop ro.product.model; getprop ro.product.manufacturer; getprop ro.serialno; wm size; dumpsys window displays | grep -o 'cur=[0-9]*x[0-9]*' | head -1"))

        $model  = if ($props.Count -gt 0) { "$($props[0])".Trim() } else { '' }
        $vendor = if ($props.Count -gt 1) { "$($props[1])".Trim() } else { '' }
        $serial = if ($props.Count -gt 2) { "$($props[2])".Trim() } else { '' }

        # "wm size" is the physical (portrait) panel; "cur=" is what the display
        # actually shows right now, which flips when the device is rotated.
        $width = 1080; $height = 1920
        $curW  = 0;    $curH   = 0
        foreach ($p in $props) {
            if ("$p" -match 'Physical size:\s*(\d+)x(\d+)') {
                $width  = [int]$Matches[1]
                $height = [int]$Matches[2]
            }
            if ("$p" -match 'cur=(\d+)x(\d+)') {
                $curW = [int]$Matches[1]
                $curH = [int]$Matches[2]
            }
        }
        if ($curW -le 0 -or $curH -le 0) { $curW = $width; $curH = $height }

        if ([string]::IsNullOrWhiteSpace($model))  { $model  = $addr }
        if ([string]::IsNullOrWhiteSpace($serial)) { $serial = $addr }

        $isNetwork = "$addr" -match '^\d{1,3}(\.\d{1,3}){3}:\d+$'

        if ($found.ContainsKey($serial)) {
            # Same physical device on a second transport - prefer ip:port.
            if ($isNetwork -and -not $found[$serial].IsNetwork) {
                $found[$serial].Addr      = $addr
                $found[$serial].IsNetwork = $true
            }
            continue
        }

        $dev = [pscustomobject]@{
            Addr      = $addr
            Serial    = $serial
            Model     = $model
            Vendor    = $vendor
            Width     = $width
            Height    = $height
            CurWidth  = $curW
            CurHeight = $curH
            IsNetwork = [bool]$isNetwork
        }
        $found[$serial] = $dev
        [void]$order.Add($dev)
    }

    @($order.ToArray())
}

# ---------------------------------------------------------------- launching

$script:Tracked = New-Object System.Collections.ArrayList

function Start-Mirror {
    param($Device, [int]$Percent, [int]$Index)

    $size   = Get-WindowSize -Width $Device.CurWidth -Height $Device.CurHeight -Percent $Percent
    $offset = $Index * 32
    $x      = 40 + $offset
    $y      = 40 + $offset

    # Each instance gets its own local port so concurrent tunnels never collide.
    $port = 27100 + ($Index * 8)

    $window = @("--window-width=$($size.Box)", "--window-height=$($size.Box)",
                "--window-x=$x", "--window-y=$y",
                # Emulate a physical (HID) keyboard so the device IME handles
                # Korean input; switch language on the device with Ctrl+Space.
                '--keyboard=uhid')

    $hwArgs = @('-s', $Device.Addr, "-m$StreamMaxSize", "--port=$port",
                "--window-title=`"$($Device.Model) $Percent%`"") + $window

    # The Qualcomm hardware encoder on some devices stays broken until reboot,
    # so keep a software-encoder command ready as a fallback.
    $swArgs = @('-s', $Device.Addr, "-m$FallbackMaxSize", "--port=$port",
                '--video-encoder=c2.android.avc.encoder',
                "--window-title=`"$($Device.Model) $Percent% SW`"") + $window

    try {
        $proc = Start-Process -FilePath $ScrExe -ArgumentList $hwArgs `
                              -WorkingDirectory $Root -PassThru -WindowStyle Hidden
    } catch {
        return "$($Device.Model): 실행 실패 - $($_.Exception.Message)"
    }

    [void]$script:Tracked.Add([pscustomobject]@{
        Proc      = $proc
        Name      = $Device.Model
        SwArgs    = $swArgs
        Retried   = $false
        StartedAt = Get-Date
    })
    return $null
}

# Grace period for the encoder fallback. A scrcpy that fails on the broken
# hardware encoder dies within a few seconds; one that runs longer than this
# was working, so a later non-zero exit means the user closed it or the
# device dropped off - neither should trigger a software-encoder relaunch.
$FallbackWindowSeconds = 15

# Poll launched instances; retry with the software encoder if one dies early.
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(1200)
$timer.Add_Tick({
    $finished = @()
    foreach ($t in @($script:Tracked)) {
        if (-not $t.Proc.HasExited) { continue }

        $lifetime = ((Get-Date) - $t.StartedAt).TotalSeconds

        if ($t.Proc.ExitCode -ne 0 -and -not $t.Retried -and $lifetime -lt $FallbackWindowSeconds) {
            $t.Retried = $true
            Set-Status "$($t.Name): 하드웨어 인코더 실패 - 소프트웨어 인코더로 다시 시도합니다."
            try {
                $t.Proc = Start-Process -FilePath $ScrExe -ArgumentList $t.SwArgs `
                                        -WorkingDirectory $Root -PassThru -WindowStyle Hidden
            } catch {
                Set-Status "$($t.Name): 소프트웨어 인코더 실행도 실패했습니다."
                $finished += $t
            }
        } else {
            $finished += $t
        }
    }
    foreach ($t in $finished) { $script:Tracked.Remove($t) }
})
$timer.Start()

# ---------------------------------------------------------------- UI wiring

$script:Cards = New-Object System.Collections.ArrayList
$script:Busy  = $false

function Get-CheckedCards {
    # Callers must wrap this in @(): PowerShell unrolls a single-element array
    # on return, and .Count on the bare object is $null, not 1.
    @($script:Cards | Where-Object { $_.Check.IsChecked })
}

# Keeps the select-all label, the launch button label and its enabled state
# in sync with the checkboxes. Nothing is selected until the user picks.
function Update-SelectionState {
    $total   = $script:Cards.Count
    $checked = @(Get-CheckedCards).Count

    if ($env:SCRCPY_GUI_DEBUG) {
        $states = ($script:Cards | ForEach-Object { '{0}={1}' -f $_.Device.Model, $_.Check.IsChecked }) -join ' '
        Add-Content -LiteralPath "$env:TEMP\scrcpy-gui-debug.log" -Encoding UTF8 `
            -Value ('{0} state total={1} checked={2} [{3}]' -f (Get-Date -Format 'HH:mm:ss.fff'), $total, $checked, $states)
    }

    $SelectAllBtn.Visibility = if ($total -gt 0) { 'Visible' } else { 'Collapsed' }
    $SelectAllBtn.Content    = if ($total -gt 0 -and $checked -eq $total) { '전체 해제' } else { '전체 선택' }
    $LaunchBtn.Content       = if ($checked -gt 0) { "미러링 시작 ($checked)" } else { '미러링 시작' }

    if (-not $script:Busy) { $LaunchBtn.IsEnabled = ($checked -gt 0) }
}

function Set-Busy {
    param([bool]$On)
    $script:Busy = $On
    $RefreshBtn.IsEnabled   = -not $On
    $SelectAllBtn.IsEnabled = -not $On
    if ($On) { $LaunchBtn.IsEnabled = $false } else { Update-SelectionState }
}

function Update-DeviceCards {
    if ($script:Busy) { return }
    Set-Busy $true

    $DeviceList.Children.Clear()
    $script:Cards.Clear()

    Set-Status '기기를 찾고 있습니다...'
    Sync-Ui
    $devices = @(Get-DeviceList)

    if ($devices.Count -eq 0) {
        [void]$DeviceList.Children.Add([Windows.Markup.XamlReader]::Parse($emptyXaml))
        $SubText.Text = '무선 디버깅이 켜진 기기를 자동으로 찾습니다'
        Set-Status '기기를 찾지 못했습니다.'
        Set-Busy $false
        return
    }

    $index = 0
    foreach ($dev in $devices) {
        $sub = '{0} · {1}x{2} · {3}' -f $dev.Vendor, $dev.CurWidth, $dev.CurHeight, $dev.Addr

        $markup = $cardXaml.Replace('__NAME__', [Security.SecurityElement]::Escape($dev.Model)).
                            Replace('__SUB__',  [Security.SecurityElement]::Escape($sub)).
                            Replace('__G__',    "grp$index")
        $card = [Windows.Markup.XamlReader]::Parse($markup)

        $nodes  = @(Get-Descendants $card)
        $entry  = [pscustomobject]@{
            Device = $dev
            Check  = ($nodes | Where-Object { "$($_.Tag)" -eq 'chk' } | Select-Object -First 1)
            PxText = ($nodes | Where-Object { "$($_.Tag)" -eq 'px' }  | Select-Object -First 1)
            Radios = @($nodes | Where-Object { "$($_.Tag)" -like 'pct:*' })
        }

        $updatePx = {
            $sel = $entry.Radios | Where-Object { $_.IsChecked } | Select-Object -First 1
            if ($sel) {
                $pct = [int]("$($sel.Tag)".Split(':')[1])
                $sz  = Get-WindowSize -Width $entry.Device.CurWidth `
                                      -Height $entry.Device.CurHeight -Percent $pct
                $entry.PxText.Text = '창 {0}x{1}' -f $sz.Width, $sz.Height
            }
        }.GetNewClosure()

        foreach ($radio in $entry.Radios) { $radio.Add_Checked($updatePx) }
        & $updatePx

        $onToggle = {
            if ($env:SCRCPY_GUI_DEBUG) {
                try {
                    Add-Content -LiteralPath "$env:TEMP\scrcpy-gui-debug.log" -Encoding UTF8 `
                        -Value ('{0} toggle fired' -f (Get-Date -Format 'HH:mm:ss.fff'))
                } catch {}
            }
            try { Update-SelectionState } catch {
                if ($env:SCRCPY_GUI_DEBUG) {
                    Add-Content -LiteralPath "$env:TEMP\scrcpy-gui-debug.log" -Encoding UTF8 `
                        -Value ('{0} ERROR {1}' -f (Get-Date -Format 'HH:mm:ss.fff'), $_.Exception.Message)
                }
            }
        }
        $entry.Check.Add_Checked($onToggle)
        $entry.Check.Add_Unchecked($onToggle)

        [void]$DeviceList.Children.Add($card)
        [void]$script:Cards.Add($entry)
        $index++
    }

    $SubText.Text = '기기 {0}대를 찾았습니다. 창 크기는 기기마다 따로 정할 수 있습니다.' -f $devices.Count
    Set-Status $null
    Set-Busy $false
}

$SelectAllBtn.Add_Click({
    if ($script:Busy) { return }
    $total = $script:Cards.Count
    if ($total -eq 0) { return }

    $selectAll = (@(Get-CheckedCards).Count -ne $total)
    foreach ($entry in $script:Cards) { $entry.Check.IsChecked = $selectAll }
    Update-SelectionState
})

# Launches are staggered through a timer instead of a blocking loop, so the
# window stays responsive and each device is started exactly once.
$script:Queue   = New-Object System.Collections.ArrayList
$script:Started = New-Object System.Collections.ArrayList
$script:Errors  = New-Object System.Collections.ArrayList

$script:LaunchTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:LaunchTimer.Interval = [TimeSpan]::FromMilliseconds(800)
$script:LaunchTimer.Add_Tick({
    if ($script:Queue.Count -eq 0) {
        $script:LaunchTimer.Stop()
        if ($script:Errors.Count -gt 0) {
            Set-Status ($script:Errors -join '   ')
        } else {
            Set-Status ('실행했습니다 - {0}' -f ($script:Started -join ', '))
        }
        Set-Busy $false
        return
    }

    $item = $script:Queue[0]
    $script:Queue.RemoveAt(0)

    Set-Status ('{0} 실행 중...' -f $item.Device.Model)
    $err = Start-Mirror -Device $item.Device -Percent $item.Percent -Index $item.Index

    if ($err) { [void]$script:Errors.Add($err) }
    else { [void]$script:Started.Add(('{0} {1}%' -f $item.Device.Model, $item.Percent)) }
})

$LaunchBtn.Add_Click({
    if ($script:Busy) { return }

    $selected = @(Get-CheckedCards)
    if ($selected.Count -eq 0) {
        Set-Status '미러링할 기기를 하나 이상 선택해주세요.'
        return
    }

    $script:Queue.Clear()
    $script:Started.Clear()
    $script:Errors.Clear()

    $index = 0
    foreach ($entry in $selected) {
        $sel = $entry.Radios | Where-Object { $_.IsChecked } | Select-Object -First 1
        $pct = if ($sel) { [int]("$($sel.Tag)".Split(':')[1]) } else { 50 }

        [void]$script:Queue.Add([pscustomobject]@{
            Device  = $entry.Device
            Percent = $pct
            Index   = $index
        })
        $index++
    }

    Set-Busy $true
    Set-Status '실행을 준비하고 있습니다...'
    $script:LaunchTimer.Start()
})

$RefreshBtn.Add_Click({ Update-DeviceCards })
$CloseBtn.Add_Click({ $win.Close() })

# Explorer "Send to" setup runs in its own console window (it asks for a
# name per device), so the GUI stays responsive.
$script:KitRoot = $PSScriptRoot
$SendToBtn.Add_Click({
    $setup = Join-Path $script:KitRoot 'send-to-setup.ps1'
    Start-Process -FilePath 'powershell.exe' -WorkingDirectory $script:KitRoot -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$setup`"")
})
$TitleBar.Add_MouseLeftButtonDown({ $win.DragMove() })
$win.Add_Closed({ $timer.Stop() })
$win.Add_ContentRendered({ Update-DeviceCards })

$win.ShowDialog() | Out-Null

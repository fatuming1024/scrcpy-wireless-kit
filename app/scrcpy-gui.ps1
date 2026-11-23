#Requires -Version 5.1
# scrcpy device launcher - Toss style GUI
# Launched by scrcpy-wireless.exe (one folder up) or app\start.bat

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

# ---------------------------------------------------------------- Language
# Korean on Korean Windows, English everywhere else.
# Override with the environment variable SCRCPY_LANG=ko or SCRCPY_LANG=en.

$Lang = if ($env:SCRCPY_LANG) { $env:SCRCPY_LANG } else { (Get-UICulture).TwoLetterISOLanguageName }
$Strings = @{
    ko = @{
        SendToBtn     = '보내기 메뉴 설정'
        SendToTip     = '탐색기 우클릭 → 보내기에 기기별 메뉴를 추가/제거합니다'
        Title         = '미러링할 기기를 선택하세요'
        SubDefault    = '무선 디버깅이 켜진 기기를 자동으로 찾습니다'
        SelectAll     = '전체 선택'
        DeselectAll   = '전체 해제'
        Refresh       = '새로고침'
        Launch        = '미러링 시작'
        LaunchN       = '미러링 시작 ({0})'
        Empty1        = '연결된 기기가 없습니다.'
        Empty2        = '기기에서 개발자 옵션 &gt; 무선 디버깅을 켠 뒤'
        Empty3        = '새로고침을 눌러주세요. 처음 연결하는 기기는 위쪽 [기기 추가]를 누르세요.'
        AddDevice     = '기기 추가'
        AddDeviceTip  = '새 기기를 페어링 코드로 연결합니다 (기기마다 처음 한 번)'
        PairTitle     = '새 기기 연결하기'
        PairSub       = '기기마다 처음 한 번만 하면 됩니다. PC와 기기가 같은 Wi-Fi에 있어야 합니다.'
        PairStep1     = '설정 → 휴대전화(태블릿) 정보 → 소프트웨어 정보 → ''빌드번호''를 7번 누릅니다. 개발자 옵션이 켜집니다. (이미 켰으면 건너뛰기)'
        PairStep2     = '설정 → 개발자 옵션 → ''무선 디버깅''을 켭니다.'
        PairStep3     = '''무선 디버깅'' 글자를 눌러 들어간 뒤 ''페어링 코드로 기기 페어링''을 누릅니다.'
        PairStep4     = '기기 화면에 나온 6자리 코드를 아래에 입력하고 [페어링]을 누릅니다. IP와 포트는 자동으로 찾습니다.'
        PairCodeLabel = '페어링 코드 (6자리)'
        PairAddrLabel = 'IP 주소:포트 — 자동으로 못 찾을 때만 입력 (예: 192.168.0.20:37215)'
        PairBtn       = '페어링'
        Cancel        = '취소'
        PairBadCode   = '6자리 숫자 코드를 입력하세요.'
        PairSearching = '기기의 페어링 창을 찾는 중입니다... 코드 창을 닫지 마세요.'
        PairNoService = '기기의 페어링 창을 찾지 못했습니다. ''페어링 코드로 기기 페어링'' 창이 열려 있는지 확인하세요. 계속 안 되면 그 창에 나온 IP 주소:포트를 아래 칸에 입력하세요.'
        PairOk        = '페어링 완료 ({0}). 기기 목록을 새로 고칩니다.'
        PairNoConnect = '페어링은 완료됐지만 연결 포트를 자동으로 찾지 못했습니다. 기기의 무선 디버깅 화면 맨 위에 있는 IP 주소 및 포트를 아래 칸에 입력하고 [연결]을 누르세요.'
        ConnAddrLabel = '기기의 무선 디버깅 화면 맨 위 IP 주소 및 포트 (예: 192.168.0.20:41234)'
        ConnBtn       = '연결'
        ConnBadAddr   = 'IP 주소:포트 형식으로 입력하세요 (예: 192.168.0.20:41234).'
        ConnConnecting = '연결하는 중...'
        ConnFail      = '연결하지 못했습니다 ({0}). 무선 디버깅 화면의 IP 주소 및 포트를 다시 확인하세요.'
        PairFail      = '페어링 실패 - 코드가 틀렸거나 만료됐을 수 있습니다. 기기에서 새 코드를 받아 다시 시도하세요. ({0})'
        LaunchFail    = '{0}: 실행 실패 - {1}'
        HwFail        = '{0}: 하드웨어 인코더 실패 - 소프트웨어 인코더로 다시 시도합니다.'
        SwFail        = '{0}: 소프트웨어 인코더 실행도 실패했습니다.'
        Searching     = '기기를 찾고 있습니다...'
        NotFound      = '기기를 찾지 못했습니다.'
        WindowSize    = '창 {0}x{1}'
        FoundN        = '기기 {0}대를 찾았습니다. 창 크기는 기기마다 따로 정할 수 있습니다.'
        Started       = '실행했습니다 - {0}'
        Starting      = '{0} 실행 중...'
        SelectOne     = '미러링할 기기를 하나 이상 선택해주세요.'
        Preparing     = '실행을 준비하고 있습니다...'
    }
    en = @{
        SendToBtn     = 'Send-to menu'
        SendToTip     = 'Add or remove per-device entries in the Explorer right-click Send to menu'
        Title         = 'Choose devices to mirror'
        SubDefault    = 'Devices with Wireless debugging ON are found automatically'
        SelectAll     = 'Select all'
        DeselectAll   = 'Deselect all'
        Refresh       = 'Refresh'
        Launch        = 'Start mirroring'
        LaunchN       = 'Start mirroring ({0})'
        Empty1        = 'No device connected.'
        Empty2        = 'Turn on Developer options &gt; Wireless debugging on the device,'
        Empty3        = 'then click Refresh. For a new device, click [Add device] at the top.'
        AddDevice     = 'Add device'
        AddDeviceTip  = 'Pair a new device with a pairing code (once per device)'
        PairTitle     = 'Connect a new device'
        PairSub       = 'Needed only once per device. The PC and the device must be on the same Wi-Fi.'
        PairStep1     = 'Settings → About phone (→ Software information) → tap ''Build number'' 7 times to turn on Developer options. (Skip if already on.)'
        PairStep2     = 'Settings → Developer options → turn on ''Wireless debugging''.'
        PairStep3     = 'Tap the words ''Wireless debugging'' to open it, then tap ''Pair device with pairing code''.'
        PairStep4     = 'Type the 6-digit code shown on the device below and click [Pair]. The IP and port are found automatically.'
        PairCodeLabel = 'Pairing code (6 digits)'
        PairAddrLabel = 'IP address:port — only if it is not found automatically (e.g. 192.168.0.20:37215)'
        PairBtn       = 'Pair'
        Cancel        = 'Cancel'
        PairBadCode   = 'Enter the 6-digit numeric code.'
        PairSearching = 'Looking for the pairing screen on the device... keep the code window open.'
        PairNoService = 'Could not find the pairing screen. Check that ''Pair device with pairing code'' is open on the device. If it still fails, type the IP address:port shown there into the box below.'
        PairOk        = 'Paired ({0}). Refreshing the device list.'
        PairNoConnect = 'Paired, but the connection port was not found automatically. Type the IP address & port shown at the top of the device''s Wireless debugging screen below and press Connect.'
        ConnAddrLabel = 'IP address & port at the top of the device''s Wireless debugging screen (e.g. 192.168.0.20:41234)'
        ConnBtn       = 'Connect'
        ConnBadAddr   = 'Enter it as IP address:port (e.g. 192.168.0.20:41234).'
        ConnConnecting = 'Connecting...'
        ConnFail      = 'Could not connect ({0}). Check the IP address & port on the Wireless debugging screen.'
        PairFail      = 'Pairing failed - the code may be wrong or expired. Get a new code on the device and try again. ({0})'
        LaunchFail    = '{0}: failed to start - {1}'
        HwFail        = '{0}: hardware encoder failed - retrying with the software encoder.'
        SwFail        = '{0}: the software encoder failed too.'
        Searching     = 'Searching for devices...'
        NotFound      = 'No device found.'
        WindowSize    = 'Window {0}x{1}'
        FoundN        = 'Found {0} device(s). Window size can be set per device.'
        Started       = 'Started - {0}'
        Starting      = 'Starting {0}...'
        SelectOne     = 'Select at least one device to mirror.'
        Preparing     = 'Getting ready...'
    }
}
$Txt = if ($Lang -eq 'ko') { $Strings.ko } else { $Strings.en }

# Replace @@Key@@ tokens in XAML with the chosen language's text.
function Expand-Text([string]$s) {
    foreach ($k in $Txt.Keys) { $s = $s.Replace("@@$k@@", $Txt[$k]) }
    $s
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
          <Button x:Name="AddDeviceBtn" Content="@@AddDevice@@" Style="{StaticResource Ghost}"
                  Height="34" ToolTip="@@AddDeviceTip@@"/>
          <Button x:Name="SendToBtn" Content="@@SendToBtn@@" Style="{StaticResource Ghost}"
                  Height="34" ToolTip="@@SendToTip@@"/>
          <Button x:Name="CloseBtn" Content="✕" Style="{StaticResource IconBtn}"/>
        </StackPanel>
      </Grid>

      <Grid Grid.Row="1" Margin="0,14,0,18">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <StackPanel Grid.Column="0">
          <TextBlock Text="@@Title@@" FontSize="23" FontWeight="Bold" Foreground="#191F28"/>
          <TextBlock x:Name="SubText" Text="@@SubDefault@@"
                     FontSize="13.5" Foreground="#8B95A1" Margin="0,7,0,0"/>
        </StackPanel>
        <Button x:Name="SelectAllBtn" Grid.Column="1" Content="@@SelectAll@@"
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
        <Button x:Name="RefreshBtn" Grid.Column="0" Content="@@Refresh@@" Style="{StaticResource Secondary}"/>
        <Button x:Name="LaunchBtn" Grid.Column="2" Content="@@Launch@@" Style="{StaticResource Primary}"
                IsEnabled="False"/>
      </Grid>

      <!-- Pairing panel: covers the device list while a new device is paired. -->
      <Border x:Name="PairPanel" Grid.Row="1" Grid.RowSpan="4" Background="White" Visibility="Collapsed">
        <Grid>
          <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
          </Grid.RowDefinitions>

          <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto" Padding="0,0,4,0">
            <StackPanel Margin="0,14,0,0">
              <TextBlock Text="@@PairTitle@@" FontSize="23" FontWeight="Bold" Foreground="#191F28"/>
              <TextBlock Text="@@PairSub@@" FontSize="13.5" Foreground="#8B95A1" Margin="0,7,0,0" TextWrapping="Wrap"/>

              <Border Background="#F9FAFB" CornerRadius="16" Padding="18,16,18,6" Margin="0,18,0,0">
                <StackPanel>
                  <Grid Margin="0,0,0,12">
                    <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <Border Width="22" Height="22" CornerRadius="11" Background="#E8F3FF" VerticalAlignment="Top" Margin="0,0,12,0">
                      <TextBlock Text="1" FontSize="12" FontWeight="Bold" Foreground="#3182F6" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <TextBlock Grid.Column="1" Text="@@PairStep1@@" FontSize="13.5" Foreground="#333D4B" TextWrapping="Wrap" LineHeight="21"/>
                  </Grid>
                  <Grid Margin="0,0,0,12">
                    <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <Border Width="22" Height="22" CornerRadius="11" Background="#E8F3FF" VerticalAlignment="Top" Margin="0,0,12,0">
                      <TextBlock Text="2" FontSize="12" FontWeight="Bold" Foreground="#3182F6" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <TextBlock Grid.Column="1" Text="@@PairStep2@@" FontSize="13.5" Foreground="#333D4B" TextWrapping="Wrap" LineHeight="21"/>
                  </Grid>
                  <Grid Margin="0,0,0,12">
                    <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <Border Width="22" Height="22" CornerRadius="11" Background="#E8F3FF" VerticalAlignment="Top" Margin="0,0,12,0">
                      <TextBlock Text="3" FontSize="12" FontWeight="Bold" Foreground="#3182F6" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <TextBlock Grid.Column="1" Text="@@PairStep3@@" FontSize="13.5" Foreground="#333D4B" TextWrapping="Wrap" LineHeight="21"/>
                  </Grid>
                  <Grid Margin="0,0,0,12">
                    <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <Border Width="22" Height="22" CornerRadius="11" Background="#E8F3FF" VerticalAlignment="Top" Margin="0,0,12,0">
                      <TextBlock Text="4" FontSize="12" FontWeight="Bold" Foreground="#3182F6" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <TextBlock Grid.Column="1" Text="@@PairStep4@@" FontSize="13.5" Foreground="#333D4B" TextWrapping="Wrap" LineHeight="21"/>
                  </Grid>
                </StackPanel>
              </Border>

              <TextBlock Text="@@PairCodeLabel@@" FontSize="13" FontWeight="SemiBold" Foreground="#4E5968" Margin="2,18,0,0"/>
              <Border Background="#F2F4F6" CornerRadius="12" Padding="14,0" Height="52" Margin="0,8,0,0">
                <TextBox x:Name="PairCode" FontSize="22" FontWeight="Bold" Foreground="#191F28"
                         BorderThickness="0" Background="Transparent" VerticalContentAlignment="Center"
                         MaxLength="6"/>
              </Border>

              <TextBlock x:Name="PairAddrLbl" Text="@@PairAddrLabel@@" FontSize="12" Foreground="#8B95A1" Margin="2,14,0,0" TextWrapping="Wrap"/>
              <Border Background="#F2F4F6" CornerRadius="10" Padding="12,0" Height="38" Margin="0,6,0,0">
                <TextBox x:Name="PairAddr" FontSize="13.5" Foreground="#333D4B"
                         BorderThickness="0" Background="Transparent" VerticalContentAlignment="Center"/>
              </Border>
            </StackPanel>
          </ScrollViewer>

          <Border x:Name="PairStatusBox" Grid.Row="1" Background="#F4F6F8" CornerRadius="12"
                  Padding="14,11" Margin="0,16,0,0" Visibility="Collapsed">
            <TextBlock x:Name="PairStatus" Text="" FontSize="12.5" Foreground="#4E5968" TextWrapping="Wrap"/>
          </Border>

          <Grid Grid.Row="2" Margin="0,18,0,0">
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="130"/>
              <ColumnDefinition Width="10"/>
              <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <Button x:Name="PairCancelBtn" Grid.Column="0" Content="@@Cancel@@" Style="{StaticResource Secondary}"/>
            <Button x:Name="PairGoBtn" Grid.Column="2" Content="@@PairBtn@@" Style="{StaticResource Primary}"/>
          </Grid>
        </Grid>
      </Border>

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
           LineHeight="25" Margin="0,54,0,54">@@Empty1@@<LineBreak/><LineBreak/>@@Empty2@@<LineBreak/>@@Empty3@@</TextBlock>
'@

$xaml      = Expand-Text $xaml
$emptyXaml = Expand-Text $emptyXaml

$win = [Windows.Markup.XamlReader]::Parse($xaml)

# Taskbar icon (the window itself is borderless).
$icoPath = Join-Path $Root 'app.ico'
if (Test-Path $icoPath) {
    try { $win.Icon = [Windows.Media.Imaging.BitmapFrame]::Create((New-Object Uri $icoPath)) } catch {}
}

$DeviceList = $win.FindName('DeviceList')
$StatusBox  = $win.FindName('StatusBox')
$StatusText = $win.FindName('StatusText')
$SubText    = $win.FindName('SubText')
$LaunchBtn  = $win.FindName('LaunchBtn')
$RefreshBtn = $win.FindName('RefreshBtn')
$SelectAllBtn = $win.FindName('SelectAllBtn')
$CloseBtn   = $win.FindName('CloseBtn')
$SendToBtn  = $win.FindName('SendToBtn')
$AddDeviceBtn  = $win.FindName('AddDeviceBtn')
$PairPanel     = $win.FindName('PairPanel')
$PairCode      = $win.FindName('PairCode')
$PairAddr      = $win.FindName('PairAddr')
$PairAddrLbl   = $win.FindName('PairAddrLbl')
$PairStatusBox = $win.FindName('PairStatusBox')
$PairStatus    = $win.FindName('PairStatus')
$PairCancelBtn = $win.FindName('PairCancelBtn')
$PairGoBtn     = $win.FindName('PairGoBtn')
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
        return ($Txt.LaunchFail -f $Device.Model, $_.Exception.Message)
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
            Set-Status ($Txt.HwFail -f $t.Name)
            try {
                $t.Proc = Start-Process -FilePath $ScrExe -ArgumentList $t.SwArgs `
                                        -WorkingDirectory $Root -PassThru -WindowStyle Hidden
            } catch {
                Set-Status ($Txt.SwFail -f $t.Name)
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
    $SelectAllBtn.Content    = if ($total -gt 0 -and $checked -eq $total) { $Txt.DeselectAll } else { $Txt.SelectAll }
    $LaunchBtn.Content       = if ($checked -gt 0) { $Txt.LaunchN -f $checked } else { $Txt.Launch }

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

    Set-Status $Txt.Searching
    Sync-Ui
    $devices = @(Get-DeviceList)

    if ($devices.Count -eq 0) {
        [void]$DeviceList.Children.Add([Windows.Markup.XamlReader]::Parse($emptyXaml))
        $SubText.Text = $Txt.SubDefault
        Set-Status $Txt.NotFound
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
                $entry.PxText.Text = $Txt.WindowSize -f $sz.Width, $sz.Height
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

    $SubText.Text = $Txt.FoundN -f $devices.Count
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
            Set-Status ($Txt.Started -f ($script:Started -join ', '))
        }
        Set-Busy $false
        return
    }

    $item = $script:Queue[0]
    $script:Queue.RemoveAt(0)

    Set-Status ($Txt.Starting -f $item.Device.Model)
    $err = Start-Mirror -Device $item.Device -Percent $item.Percent -Index $item.Index

    if ($err) { [void]$script:Errors.Add($err) }
    else { [void]$script:Started.Add(('{0} {1}%' -f $item.Device.Model, $item.Percent)) }
})

$LaunchBtn.Add_Click({
    if ($script:Busy) { return }

    $selected = @(Get-CheckedCards)
    if ($selected.Count -eq 0) {
        Set-Status $Txt.SelectOne
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
    Set-Status $Txt.Preparing
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
# ---------------------------------------------------------------- pairing
# "Add device": the user types the 6-digit code from the device's
# "Pair device with pairing code" screen. The pairing port is found over
# mDNS (_adb-tls-pairing), then "adb pair" and "adb connect" run in a
# background job so the window stays responsive.

$script:PairJob = $null

$script:PairWork = {
    param($AdbExe, $Code, $Addr, $AllowRestart, $ConnectTo)
    $env:ADB_MDNS_OPENSCREEN = '1'
    function A { & $AdbExe @args 2>&1 | ForEach-Object { "$_" } }
    $res = [ordered]@{ Ok = $false; Stage = ''; Detail = '' }

    # Connect-only mode: the user typed the "IP address & port" shown at the
    # top of the device's Wireless debugging screen (already paired).
    function Wait-Online([string]$target) {
        for ($i = 0; $i -lt 6; $i++) {
            if (@(A devices) -match ('^' + [regex]::Escape($target) + '\s+device$')) { return $true }
            Start-Sleep -Milliseconds 500
        }
        $false
    }
    if ($ConnectTo) {
        $c = (@(A connect $ConnectTo) -join ' ').Trim()
        $ok = ($c -match 'connected to') -and (Wait-Online $ConnectTo)
        if (-not $ok) { A disconnect $ConnectTo | Out-Null }
        return [pscustomobject]@{ Ok = $true; Connected = $ok; Stage = 'connect'; Detail = "$ConnectTo - $c" }
    }

    if (-not $Addr) {
        $start = Get-Date; $restarted = $false
        while (-not $Addr -and ((Get-Date) - $start).TotalSeconds -lt 15) {
            foreach ($l in @(A mdns services)) {
                if ($l -match '_adb-tls-pairing\._tcp\s+(\S+:\d+)') { $Addr = $Matches[1]; break }
            }
            if (-not $Addr) {
                # A stale adb server can miss the announcement; restart once,
                # but never while scrcpy is running (it would cut mirroring).
                if (-not $restarted -and $AllowRestart -and ((Get-Date) - $start).TotalSeconds -gt 3) {
                    A kill-server | Out-Null; A start-server | Out-Null; $restarted = $true
                }
                Start-Sleep -Milliseconds 700
            }
        }
        if (-not $Addr) { $res.Stage = 'nosvc'; return [pscustomobject]$res }
    }

    $log = Join-Path $env:TEMP 'scrcpy-wireless-pair.log'
    function Log([string]$m) { try { Add-Content -LiteralPath $log -Value ("{0:HH:mm:ss} {1}" -f (Get-Date), $m) -Encoding UTF8 } catch {} }
    try { Set-Content -LiteralPath $log -Value "pair $Addr" -Encoding UTF8 } catch {}

    $out = (@(A pair $Addr $Code) -join ' ').Trim()
    Log "pair: $out"
    if ($out -notmatch 'Successfully paired') {
        $res.Stage = 'fail'; $res.Detail = $out; return [pscustomobject]$res
    }
    $res.Ok = $true; $res.Detail = $Addr
    $res.Connected = $false

    # Connect right away so the device shows up in the list. The connect port
    # differs from the pairing port. After pairing, the device announces it
    # by multicast, which the Windows firewall often drops for this adb.exe,
    # so "adb mdns services" alone is not enough. Try, in order:
    #   1. adb's own mDNS list (match by guid or IP)
    #   2. an mDNS SRV query asking for a unicast reply (reply is allowed)
    #   3. restart the adb server once (fresh queries), if nothing is running
    # If none works, the panel switches to connect mode (address typed in).
    $guid = if ($out -match 'guid=([^\]\s]+)') { $Matches[1] } else { '' }
    $ip = ($Addr -split ':')[0]
    Log "guid=$guid ip=$ip"

    function Get-SrvPort([string]$ip, [string]$name) {
        $u = New-Object Net.Sockets.UdpClient
        try {
            $u.Client.ReceiveTimeout = 1200
            $q = New-Object 'Collections.Generic.List[byte]'
            $q.AddRange([byte[]](0x12, 0x34, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0))
            foreach ($p in $name.Split('.')) {
                $b = [Text.Encoding]::ASCII.GetBytes($p); $q.Add([byte]$b.Length); $q.AddRange($b)
            }
            # Type SRV, class IN with the unicast-response bit. Sent to the
            # mDNS multicast group: some phones ignore direct unicast queries
            # but answer this one straight back to our socket.
            $q.AddRange([byte[]](0, 0, 33, 0x80, 1))
            [void]$u.Send($q.ToArray(), $q.Count, '224.0.0.251', 5353)
            $ep = New-Object Net.IPEndPoint ([Net.IPAddress]::Any, 0)
            while ($true) {
                $r = $u.Receive([ref]$ep)
                if ($ep.Address.ToString() -ne $ip) { continue }
                $port = Get-SrvPortFromReply $r
                if ($port -gt 0) { return $port }
            }
        } catch {} finally { $u.Close() }
        0
    }

    # Walk every resource record of a DNS reply and return the first SRV port.
    function Get-SrvPortFromReply([byte[]]$r) {
        try {
            $skipName = { param($i) while ($i -lt $r.Length) { $l = $r[$i]; if ($l -eq 0) { return $i + 1 }; if (($l -band 0xC0) -eq 0xC0) { return $i + 2 }; $i += 1 + $l }; $i }
            $i = 12
            $qd = $r[4] * 256 + $r[5]
            for ($k = 0; $k -lt $qd; $k++) { $i = (& $skipName $i) + 4 }
            $rrs = ($r[6] * 256 + $r[7]) + ($r[8] * 256 + $r[9]) + ($r[10] * 256 + $r[11])
            for ($k = 0; $k -lt $rrs -and $i -lt $r.Length; $k++) {
                $i = & $skipName $i
                $type = $r[$i] * 256 + $r[$i + 1]
                $len  = $r[$i + 8] * 256 + $r[$i + 9]
                $d = $i + 10
                if ($type -eq 33) { return $r[$d + 4] * 256 + $r[$d + 5] }
                $i = $d + $len
            }
        } catch {}
        0
    }

    function Test-Online {
        foreach ($l in @(A devices)) {
            if ($l -match '^(\S+)\s+device$' -and ($Matches[1].StartsWith("$ip`:") -or ($guid -and $Matches[1].StartsWith($guid)))) { return $true }
        }
        $false
    }

    $start = Get-Date; $restarted = $false
    while (((Get-Date) - $start).TotalSeconds -lt 10) {
        if (Test-Online) { $res.Connected = $true; break }
        $target = ''
        foreach ($l in @(A mdns services)) {
            if ($l -match '_adb-tls-connect\._tcp\s+(\S+:\d+)' -and (($guid -and $l.StartsWith($guid)) -or $Matches[1].StartsWith("$ip`:"))) { $target = $Matches[1]; break }
        }
        if (-not $target -and $guid) {
            $port = Get-SrvPort $ip "$guid._adb-tls-connect._tcp.local"
            if ($port -gt 0) { $target = "$ip`:$port" }
        }
        if ($target) {
            $c = (@(A connect $target) -join ' ').Trim()
            Log "connect $target -> $c"
            if (Test-Online) { $res.Connected = $true; break }
        } elseif (-not $restarted -and $AllowRestart -and ((Get-Date) - $start).TotalSeconds -gt 4) {
            Log 'restart adb server'
            A kill-server | Out-Null; A start-server | Out-Null; $restarted = $true
        }
        Start-Sleep -Milliseconds 800
    }
    Log "connected=$($res.Connected)"
    [pscustomobject]$res
}

function Set-PairStatus([string]$msg) {
    if ([string]::IsNullOrWhiteSpace($msg)) { $PairStatusBox.Visibility = 'Collapsed' }
    else { $PairStatus.Text = $msg; $PairStatusBox.Visibility = 'Visible' }
}

function Set-PairBusy([bool]$on) {
    $PairGoBtn.IsEnabled = -not $on
    $PairCode.IsEnabled  = -not $on
    $PairAddr.IsEnabled  = -not $on
}

$script:PairMode = 'pair'
function Set-PairMode([string]$mode) {
    $script:PairMode = $mode
    if ($mode -eq 'connect') {
        $PairAddrLbl.Text  = $Txt.ConnAddrLabel
        $PairGoBtn.Content = $Txt.ConnBtn
        $PairAddr.Text     = ''
    } else {
        $PairAddrLbl.Text  = $Txt.PairAddrLabel
        $PairGoBtn.Content = $Txt.PairBtn
    }
}

$script:PairTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:PairTimer.Interval = [TimeSpan]::FromMilliseconds(300)
$script:PairTimer.Add_Tick({
    $job = $script:PairJob
    if (-not $job -or $job.State -eq 'Running' -or $job.State -eq 'NotStarted') { return }
    $script:PairTimer.Stop()
    $r = @(Receive-Job $job -ErrorAction SilentlyContinue) | Select-Object -Last 1
    Remove-Job $job -Force -ErrorAction SilentlyContinue
    $script:PairJob = $null
    Set-PairBusy $false

    if ($r -and $r.Ok -and $r.Connected) {
        Set-PairStatus ($Txt.PairOk -f $r.Detail)
        $PairPanel.Visibility = 'Collapsed'
        Update-DeviceCards
    } elseif ($r -and $r.Stage -eq 'connect') {
        Set-PairStatus ($Txt.ConnFail -f $r.Detail)
    } elseif ($r -and $r.Ok) {
        # Paired, but the connect port was not found automatically. Switch the
        # panel to connect mode: the user types the address shown at the top
        # of the device's Wireless debugging screen.
        Set-PairMode 'connect'
        Set-PairStatus $Txt.PairNoConnect
        [void]$PairAddr.Focus()
    } elseif ($r -and $r.Stage -eq 'nosvc') {
        Set-PairStatus $Txt.PairNoService
    } else {
        $detail = if ($r) { $r.Detail } else { "$($job.State)" }
        Set-PairStatus ($Txt.PairFail -f $detail)
    }
})

$AddDeviceBtn.Add_Click({
    if ($script:Busy -or $script:PairJob) { return }
    Set-PairMode 'pair'
    $PairCode.Text = ''
    $PairAddr.Text = ''
    Set-PairStatus $null
    Set-PairBusy $false
    $PairPanel.Visibility = 'Visible'
    [void]$PairCode.Focus()
})

$PairCancelBtn.Add_Click({
    if ($script:PairJob) {
        $script:PairTimer.Stop()
        Stop-Job $script:PairJob -ErrorAction SilentlyContinue
        Remove-Job $script:PairJob -Force -ErrorAction SilentlyContinue
        $script:PairJob = $null
    }
    Set-PairBusy $false
    $PairPanel.Visibility = 'Collapsed'
})

$PairGoBtn.Add_Click({
    if ($script:PairJob) { return }
    if ($script:PairMode -eq 'connect') {
        $target = "$($PairAddr.Text)".Trim()
        if ($target -notmatch '^\d{1,3}(\.\d{1,3}){3}:\d{2,5}$') { Set-PairStatus $Txt.ConnBadAddr; return }
        Set-PairBusy $true
        Set-PairStatus $Txt.ConnConnecting
        $script:PairJob = Start-Job -ScriptBlock $script:PairWork -ArgumentList $AdbExe, '', '', $false, $target
        $script:PairTimer.Start()
        return
    }
    $code = "$($PairCode.Text)".Trim()
    if ($code -notmatch '^\d{6}$') { Set-PairStatus $Txt.PairBadCode; return }
    $addr = "$($PairAddr.Text)".Trim()
    $allowRestart = @(Get-Process scrcpy -ErrorAction SilentlyContinue).Count -eq 0

    Set-PairBusy $true
    Set-PairStatus $Txt.PairSearching
    $script:PairJob = Start-Job -ScriptBlock $script:PairWork -ArgumentList $AdbExe, $code, $addr, $allowRestart
    $script:PairTimer.Start()
})

# Enter in the code box starts pairing.
$PairCode.Add_KeyDown({
    if ($_.Key -eq 'Return') { $PairGoBtn.RaiseEvent((New-Object Windows.RoutedEventArgs ([Windows.Controls.Button]::ClickEvent))) }
})

$TitleBar.Add_MouseLeftButtonDown({ $win.DragMove() })
$win.Add_Closed({ $timer.Stop() })
$win.Add_ContentRendered({ Update-DeviceCards })

$win.ShowDialog() | Out-Null

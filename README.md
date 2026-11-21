# scrcpy Wireless Kit (Windows)

[English](#english) · [한국어](#한국어)

Windows helper scripts for [scrcpy](https://github.com/Genymobile/scrcpy): mirror one or more Android devices over **Wireless debugging** (no USB cable), and send files from Explorer to a device with a right-click.

> Not affiliated with the scrcpy project. scrcpy itself is **not** included in this repository — download it separately (see Setup).

---

## English

### Features

| | What it does |
|---|---|
| **One launcher** (`scrcpy-wireless.bat`) | The only file you run. Finds wireless devices automatically, lets you tick the ones to mirror and pick a window size per device (30 / 50 / 75 / 100 %), then opens them all at once. UI text is Korean. |
| **Auto-connect** | Uses mDNS to find each device's Wireless-debugging port, which changes every time it is turned on. You never type an IP or port. If the adb server has gone stale, it restarts it and searches again. |
| **Send to device** (launcher button **"보내기 메뉴 설정"**) | Adds **Right-click → Send to → "Send to &lt;device&gt;"** to Explorer. Files and folders go to the device's `Download` folder over Wi-Fi, with no mirroring window needed. |
| **Korean typing** | Mirror windows use `--keyboard=uhid` (the device sees a physical keyboard), so the device's own keyboard handles Korean and other languages. |
| **Encoder fallback** | If the device's hardware video encoder fails at start-up, the launcher retries with the software encoder. |
| **Rotation-aware sizing** | Window size is computed from the device's *current* orientation, and stream quality stays high when you resize the window. |

### Requirements

- Windows 10 / 11 (Windows PowerShell 5.1, built in)
- [scrcpy](https://github.com/Genymobile/scrcpy/releases) **win64** release (tested with v4.1)
- Android 11+ (for Wireless debugging); PC and device on the same Wi-Fi / LAN

### Setup

1. Download the scrcpy win64 zip and extract it.
2. Copy **all files of this repository into that same folder**, next to `scrcpy.exe` and `adb.exe`. The scripts use the `adb.exe` in their own folder.
3. **Pair each device once:**
   1. On the device: *Settings → Developer options → Wireless debugging → ON*.
   2. Tap **Pair device with pairing code**. It shows an `IP:port` and a 6-digit code.
   3. In the scrcpy folder, run:
      ```
      .\adb.exe pair <IP:port> <code>
      ```
4. Double-click **`scrcpy-wireless.bat`**.
5. *(Optional)* With your devices' Wireless debugging ON, click **"보내기 메뉴 설정"** (top of the launcher) → `1`. It creates one "Send to" entry per device and asks you for a name for each one.

### Does it reconnect automatically?

**Mostly yes, with one catch:**

- **Pairing is one-time.** After that, whenever the device is on the same network *with Wireless debugging ON*, the launcher or the Send-to menu finds it and connects automatically, even though the port has changed.
- **The catch:** Android **switches Wireless debugging OFF** whenever Wi-Fi drops or the device reboots. This is an Android security behaviour and cannot be disabled. When that happens, turn it back on before you connect.
  - Tip: *Developer options → Quick settings developer tiles → Wireless debugging* adds a one-tap toggle to the notification shade.
- Connections are made **when you run the launcher or send a file**. Nothing runs in the background.
- Rarely, a device forgets the pairing. The symptom is that the device is found but the connection fails. Pair it again (Setup step 3).

### Sending files

- Right-click a file or folder → **Send to → "Send to &lt;name&gt;"**. On Windows 11, choose *Show more options* first.
- Files land in `/sdcard/Download/` on the device. A folder with a name that already exists gets ` (2)` added.
- Korean and other non-ASCII file and folder names are supported. The script works around two `adb push` bugs with such names.
- After pairing a new device, click **"보내기 메뉴 설정"** → `1` again. To remove the entries, choose `2`.
- Alternative: drag files onto an open scrcpy window. This is built into scrcpy, and `.apk` files are installed instead of copied.

### Tips / known limitations

- **Korean input:** keep the PC IME in English mode and switch language on the device. With Gboard, press `Ctrl+Space`; with the Samsung Keyboard, press `Shift+Space`. Or copy text on the PC and press `Ctrl+V` in the mirror window.
- **Games (Unity, etc.)** usually ignore the mouse wheel. Use left-click drag instead.
- PowerShell scripts must stay saved as **UTF-8 with BOM**. Otherwise Windows PowerShell 5.1 shows Korean text as garbage. Batch files must stay ASCII.
- Debug log for the GUI: set `SCRCPY_GUI_DEBUG=1`. The log goes to `%TEMP%\scrcpy-gui-debug.log`.

### Files

| File | Purpose |
|---|---|
| `scrcpy-wireless.bat` | **The one to run.** Opens the launcher |
| `scrcpy-gui.ps1` | Launcher window (internal) |
| `send-to-setup.ps1` | "Send to" menu setup; opened by the launcher button (internal) |
| `send-to-device.ps1` | Sends files to a device; called by the "Send to" entries (internal) |

### License

The scripts in this repository are under the MIT License (see `LICENSE`). scrcpy is © Genymobile / Romain Vimont, Apache License 2.0. If you redistribute the scrcpy binaries together with these scripts, keep scrcpy's own `LICENSE` and third-party notices (FFmpeg, SDL, libusb, adb).

---

## 한국어

### 기능

| | 설명 |
|---|---|
| **실행 파일 하나** (`scrcpy-wireless.bat`) | 이 파일 하나만 실행하면 됩니다. 무선 기기를 자동으로 찾아 목록으로 보여줍니다. 미러링할 기기를 체크하고 기기별 창 크기(30 / 50 / 75 / 100%)를 고른 뒤 한 번에 실행합니다. |
| **자동 연결** | 무선 디버깅 포트는 켤 때마다 바뀌는데, mDNS로 이 포트를 자동으로 찾습니다. IP나 포트를 입력할 필요가 없습니다. adb 서버가 오래 켜져 있어 기기를 못 찾으면 서버를 재시작해서 다시 찾습니다. |
| **기기로 보내기** (런처 상단 **"보내기 메뉴 설정"** 버튼) | 탐색기 **우클릭 → 보내기 → "Send to &lt;기기&gt;"** 메뉴를 추가합니다. 파일과 폴더가 Wi-Fi로 기기의 `Download` 폴더에 복사되고, 미러링 창을 띄우지 않아도 됩니다. |
| **한글 입력** | 미러링 창을 `--keyboard=uhid`로 실행합니다. 기기는 실제 키보드가 연결된 것으로 인식하고, 기기 쪽 키보드 앱이 한글을 입력합니다. |
| **인코더 자동 전환** | 기기의 하드웨어 영상 인코더가 시작 직후 실패하면 소프트웨어 인코더로 다시 실행합니다. |
| **회전 대응 창 크기** | 기기의 **현재 방향**(세로/가로)을 기준으로 창 크기를 계산합니다. 창을 키워도 화질이 유지됩니다. |

### 필요 환경

- Windows 10 / 11 (Windows PowerShell 5.1 기본 내장)
- [scrcpy](https://github.com/Genymobile/scrcpy/releases) **win64** 배포판 (v4.1에서 테스트)
- Android 11 이상 (무선 디버깅 지원). PC와 기기가 같은 Wi-Fi / 공유기에 연결되어 있어야 합니다.

### 설치

1. scrcpy win64 zip을 받아 압축을 풉니다.
2. 이 저장소의 **파일 전부를 그 폴더에 복사**합니다. `scrcpy.exe`, `adb.exe`와 같은 위치여야 합니다. 스크립트가 같은 폴더의 `adb.exe`를 사용하기 때문입니다.
3. **기기마다 한 번 페어링합니다:**
   1. 기기에서 *설정 → 개발자 옵션 → 무선 디버깅 → 켜기*.
   2. **페어링 코드로 기기 페어링**을 누르면 `IP:포트`와 6자리 코드가 나옵니다.
   3. scrcpy 폴더에서 아래 명령을 실행합니다:
      ```
      .\adb.exe pair <IP:포트> <코드>
      ```
4. **`scrcpy-wireless.bat`**을 더블클릭합니다.
5. *(선택)* 기기들의 무선 디버깅을 켠 상태에서 런처 상단의 **"보내기 메뉴 설정"** → `1`을 누릅니다. 기기마다 이름을 물어본 뒤 "보내기" 메뉴를 하나씩 만듭니다.

### 다시 네트워크에 들어오면 자동으로 연결되나요?

**대부분은 그렇습니다. 다만 조건이 하나 있습니다:**

- **페어링은 한 번만** 하면 됩니다. 그 뒤로는 기기가 같은 네트워크에 있고 **무선 디버깅이 켜져 있으면**, 런처나 보내기 메뉴가 기기를 찾아 자동으로 연결합니다. 포트가 바뀌어도 상관없습니다.
- **조건:** 안드로이드는 **Wi-Fi가 끊기거나 재부팅하면 무선 디버깅을 자동으로 끕니다.** 보안 때문에 들어간 동작이라 끌 수 없습니다. 이럴 때는 연결 전에 무선 디버깅을 다시 켜야 합니다.
  - 팁: *개발자 옵션 → 빠른 설정 개발자 타일 → 무선 디버깅*을 켜 두면 상단 바를 내려서 한 번에 켤 수 있습니다.
- 연결은 **런처를 실행하거나 파일을 보낼 때** 이루어집니다. 백그라운드에서 상주하며 연결하지는 않습니다.
- 드물게 기기 쪽 페어링 정보가 지워질 수 있습니다. 기기는 찾았는데 연결이 실패하면 이 경우이니, 설치 3단계(페어링)를 다시 해 주세요.

### 파일 보내기

- 파일이나 폴더를 우클릭 → **보내기 → "Send to &lt;이름&gt;"**을 누릅니다. Windows 11에서는 먼저 *추가 옵션 표시*를 누르세요.
- 기기의 `/sdcard/Download/`에 저장됩니다. 같은 이름의 폴더가 이미 있으면 이름 뒤에 ` (2)`가 붙습니다.
- 한글 파일 이름과 폴더 이름도 됩니다. `adb push`에는 한글 이름 관련 버그가 2가지 있는데, 스크립트가 이를 피해 갑니다.
- 기기를 새로 페어링했으면 **"보내기 메뉴 설정"** → `1`을 다시 누르세요. 메뉴를 지우려면 `2`를 고릅니다.
- 다른 방법: 열려 있는 scrcpy 창에 파일을 끌어다 놓아도 됩니다(scrcpy 기본 기능). `.apk` 파일은 복사되지 않고 바로 설치됩니다.

### 팁 / 알려진 제한

- **한글 입력:** PC 입력기는 영문 상태로 두고, 기기 쪽에서 한/영을 바꿉니다. Gboard는 `Ctrl+Space`, 삼성 키보드는 `Shift+Space`입니다. PC에서 복사한 뒤 미러링 창에서 `Ctrl+V`로 붙여넣어도 됩니다.
- **게임(Unity 등)**은 대부분 마우스 휠을 무시합니다. 왼쪽 버튼을 누른 채 드래그하세요.
- PowerShell 스크립트(`.ps1`)는 **UTF-8 BOM**으로 저장해야 합니다. 그렇지 않으면 PowerShell 5.1에서 한글이 깨집니다. 배치 파일(`.bat`)은 영문(ASCII)만 써야 합니다.
- GUI 디버그 로그: `SCRCPY_GUI_DEBUG=1`로 설정하면 `%TEMP%\scrcpy-gui-debug.log`에 기록됩니다.

### 파일 구성

| 파일 | 용도 |
|---|---|
| `scrcpy-wireless.bat` | **이것만 실행하면 됩니다.** 런처를 엽니다 |
| `scrcpy-gui.ps1` | 런처 화면 (내부용) |
| `send-to-setup.ps1` | 보내기 메뉴 설정. 런처 버튼이 엽니다 (내부용) |
| `send-to-device.ps1` | 파일을 기기로 보내는 본체. 보내기 메뉴가 호출합니다 (내부용) |

### 라이선스

이 저장소의 스크립트는 MIT 라이선스입니다(`LICENSE` 참조). scrcpy는 © Genymobile / Romain Vimont, Apache License 2.0입니다. scrcpy 실행 파일을 함께 재배포한다면 scrcpy의 `LICENSE`와 포함된 구성요소(FFmpeg, SDL, libusb, adb)의 고지를 그대로 유지해야 합니다.

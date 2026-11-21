# Draws the app icon (blue rounded square, white phone, Wi-Fi waves) at
# several sizes and writes them into one multi-size .ico (PNG entries).
#   powershell -ExecutionPolicy Bypass -File make-icon.ps1 [-Out app.ico]

param([string]$Out = (Join-Path $PSScriptRoot 'app.ico'))

Add-Type -AssemblyName System.Drawing

function New-RoundRect([single]$x, [single]$y, [single]$w, [single]$h, [single]$r) {
    $p = New-Object Drawing.Drawing2D.GraphicsPath
    $d = 2 * $r
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    $p
}

function New-IconPng([int]$size) {
    $bmp = New-Object Drawing.Bitmap $size, $size, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.PixelOffsetMode = 'HighQuality'
    $s = $size / 256.0          # everything is designed on a 256 grid

    # Background: rounded square with a vertical blue gradient.
    $bg = New-RoundRect (8*$s) (8*$s) (240*$s) (240*$s) (56*$s)
    $grad = New-Object Drawing.Drawing2D.LinearGradientBrush (
        (New-Object Drawing.PointF 0, (8*$s)), (New-Object Drawing.PointF 0, (248*$s)),
        [Drawing.Color]::FromArgb(0x4A, 0x94, 0xF8), [Drawing.Color]::FromArgb(0x1B, 0x64, 0xDA))
    $g.FillPath($grad, $bg)

    $white = [Drawing.Color]::White
    $stroke = [single][Math]::Max(1.5, 14 * $s)

    # Phone body (outline) with a filled screen.
    $phone = New-RoundRect (70*$s) (78*$s) (92*$s) (150*$s) (18*$s)
    $pen = New-Object Drawing.Pen $white, $stroke
    $g.DrawPath($pen, $phone)
    if ($size -ge 32) {
        $screen = New-RoundRect (86*$s) (100*$s) (60*$s) (98*$s) (6*$s)
        $g.FillPath((New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(150, 255, 255, 255))), $screen)
    }

    # Wi-Fi waves to the upper right of the phone.
    $cx = 184 * $s; $cy = 104 * $s
    $wave = New-Object Drawing.Pen $white, ([single][Math]::Max(1.5, 13 * $s))
    $wave.StartCap = 'Round'; $wave.EndCap = 'Round'
    $radii = if ($size -ge 32) { @(20, 42, 64) } else { @(28, 58) }
    foreach ($r in $radii) {
        $rr = $r * $s
        $g.DrawArc($wave, $cx - $rr, $cy - $rr, 2*$rr, 2*$rr, 225, 90)
    }
    $dot = 11 * $s
    $g.FillEllipse((New-Object Drawing.SolidBrush $white), $cx - $dot, $cy - $dot, 2*$dot, 2*$dot)

    $g.Dispose()
    $bmp
}

# 256 px entry: PNG. Smaller entries: classic 32-bit DIB (BITMAPINFOHEADER +
# bottom-up BGRA rows + 1-bit AND mask), which every Windows API can read.
function ConvertTo-IcoEntry([Drawing.Bitmap]$bmp) {
    $size = $bmp.Width
    $ms = New-Object IO.MemoryStream
    if ($size -ge 256) {
        $bmp.Save($ms, [Drawing.Imaging.ImageFormat]::Png)
        return , $ms.ToArray()
    }
    $w = New-Object IO.BinaryWriter $ms
    $w.Write([uint32]40); $w.Write([int32]$size); $w.Write([int32]($size * 2))
    $w.Write([uint16]1); $w.Write([uint16]32); $w.Write([uint32]0)
    $w.Write([uint32]($size * $size * 4)); $w.Write([int32]0); $w.Write([int32]0)
    $w.Write([uint32]0); $w.Write([uint32]0)
    for ($y = $size - 1; $y -ge 0; $y--) {
        for ($x = 0; $x -lt $size; $x++) {
            $c = $bmp.GetPixel($x, $y)
            $w.Write([byte]$c.B); $w.Write([byte]$c.G); $w.Write([byte]$c.R); $w.Write([byte]$c.A)
        }
    }
    $maskRow = [int]([Math]::Ceiling($size / 32.0) * 4)
    for ($y = 0; $y -lt $size; $y++) { $w.Write((New-Object byte[] $maskRow)) }   # alpha does the masking
    $w.Flush()
    , $ms.ToArray()
}

$sizes = 16, 20, 24, 32, 40, 48, 64, 128, 256
$images = foreach ($sz in $sizes) {
    $b = New-IconPng $sz
    , (ConvertTo-IcoEntry $b)
    if ($sz -eq 256) { $b.Save([IO.Path]::ChangeExtension($Out, '.png'), [Drawing.Imaging.ImageFormat]::Png) }
    $b.Dispose()
}

# ICO container: ICONDIR + one ICONDIRENTRY per image + PNG payloads.
$fs = New-Object IO.MemoryStream
$bw = New-Object IO.BinaryWriter $fs
$bw.Write([uint16]0); $bw.Write([uint16]1); $bw.Write([uint16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) {
    $sz = $sizes[$i]; $data = $images[$i]
    $dim = if ($sz -ge 256) { 0 } else { $sz }
    $bw.Write([byte]$dim); $bw.Write([byte]$dim); $bw.Write([byte]0); $bw.Write([byte]0)
    $bw.Write([uint16]1); $bw.Write([uint16]32)
    $bw.Write([uint32]$data.Length); $bw.Write([uint32]$offset)
    $offset += $data.Length
}
foreach ($data in $images) { $bw.Write($data) }
$bw.Flush()
[IO.File]::WriteAllBytes($Out, $fs.ToArray())
"Wrote $Out ($($sizes.Count) sizes) and a 256 px PNG preview"

# Regenerate all platform icons from the brand mark.
#
# Source: assets/icons/icon_maskable_512x512.png (centered "g" brand mark
# with safe-zone padding suitable for both standard and maskable use).
#
# Targets:
#   - Web PWA icons   (web/icons/icon_*.png + maskable variants)
#   - Android launcher (mipmap-*/ic_launcher.png + _round.png)
#   - iOS AppIcon set  (ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png)
#
# Uses System.Drawing (built into Windows / .NET Framework) — no external
# dependencies.

[CmdletBinding()]
param(
    [string]$Source = (Join-Path $PSScriptRoot "..\assets\icons\icon_maskable_512x512.png"),
    [string]$Root   = (Join-Path $PSScriptRoot "..")
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$Source = (Resolve-Path $Source).Path
$Root   = (Resolve-Path $Root).Path

Write-Host "Source: $Source"
Write-Host "Root  : $Root"

if (-not (Test-Path $Source)) { throw "Source brand mark not found: $Source" }

# Load the source into memory so the file is not locked on disk
# (we overwrite some of the same files later in this run).
$srcBytes  = [System.IO.File]::ReadAllBytes($Source)
$srcStream = New-Object System.IO.MemoryStream (,$srcBytes)
$src       = [System.Drawing.Image]::FromStream($srcStream)

function Save-Resized {
    param(
        [int]$Size,
        [string]$OutPath
    )
    $dir = Split-Path -Parent $OutPath
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    $bmp = New-Object System.Drawing.Bitmap $Size, $Size
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CompositingQuality   = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.InterpolationMode    = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode        = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode      = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($script:src, 0, 0, $Size, $Size)
    $g.Dispose()
    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "  wrote $OutPath ($Size x $Size)"
}

# ─── Web PWA icons ──────────────────────────────────────────────────────────
$webIcons = Join-Path $Root "web\icons"
$webSizes = 42, 56, 81, 108, 120, 152, 180, 192, 256, 384, 512, 1024
Write-Host "`n[web/icons]"
foreach ($s in $webSizes) {
    Save-Resized -Size $s -OutPath (Join-Path $webIcons ("icon_{0}x{0}.png" -f $s))
}
# Maskable variants reuse the same centered source (it already has safe-zone)
Save-Resized -Size 192 -OutPath (Join-Path $webIcons "icon_maskable_192x192.png")
Save-Resized -Size 512 -OutPath (Join-Path $webIcons "icon_maskable_512x512.png")

# Mirror to assets/icons so the in-app references stay in sync
$assetIcons = Join-Path $Root "assets\icons"
Write-Host "`n[assets/icons]"
foreach ($s in $webSizes) {
    Save-Resized -Size $s -OutPath (Join-Path $assetIcons ("icon_{0}x{0}.png" -f $s))
}
Save-Resized -Size 192 -OutPath (Join-Path $assetIcons "icon_maskable_192x192.png")
Save-Resized -Size 512 -OutPath (Join-Path $assetIcons "icon_maskable_512x512.png")

# ─── Android launcher icons ─────────────────────────────────────────────────
$androidMipmap = Join-Path $Root "android\app\src\main\res"
$androidDensities = @{
    "mipmap-mdpi"    = 48
    "mipmap-hdpi"    = 72
    "mipmap-xhdpi"   = 96
    "mipmap-xxhdpi"  = 144
    "mipmap-xxxhdpi" = 192
}
Write-Host "`n[android]"
foreach ($d in $androidDensities.GetEnumerator()) {
    $dir = Join-Path $androidMipmap $d.Key
    Save-Resized -Size $d.Value -OutPath (Join-Path $dir "ic_launcher.png")
    Save-Resized -Size $d.Value -OutPath (Join-Path $dir "ic_launcher_round.png")
}

# ─── iOS AppIcon set ────────────────────────────────────────────────────────
$ios = Join-Path $Root "ios\Runner\Assets.xcassets\AppIcon.appiconset"
# (filename, pixel-size) pairs — must match Contents.json
$iosIcons = @(
    @("Icon-App-20x20@1x.png",     20),
    @("Icon-App-20x20@2x.png",     40),
    @("Icon-App-20x20@3x.png",     60),
    @("Icon-App-29x29@1x.png",     29),
    @("Icon-App-29x29@2x.png",     58),
    @("Icon-App-29x29@3x.png",     87),
    @("Icon-App-40x40@1x.png",     40),
    @("Icon-App-40x40@2x.png",     80),
    @("Icon-App-40x40@3x.png",    120),
    @("Icon-App-60x60@2x.png",    120),
    @("Icon-App-60x60@3x.png",    180),
    @("Icon-App-76x76@1x.png",     76),
    @("Icon-App-76x76@2x.png",    152),
    @("Icon-App-83.5x83.5@2x.png",167),
    @("Icon-App-1024x1024@1x.png",1024),
    # Legacy non-@scale filenames still on disk — keep in sync to avoid stale art.
    @("Icon-App-20x20.png",        20),
    @("Icon-App-29x29.png",        29),
    @("Icon-App-40x40.png",        40),
    @("Icon-App-58x58.png",        58),
    @("Icon-App-60x60.png",        60),
    @("Icon-App-76x76.png",        76),
    @("Icon-App-80x80.png",        80),
    @("Icon-App-87x87.png",        87),
    @("Icon-App-90x90.png",        90)
)
Write-Host "`n[ios]"
foreach ($pair in $iosIcons) {
    $name = $pair[0]; $size = [int]$pair[1]
    $out = Join-Path $ios $name
    if ((Test-Path $out) -or ($name -match '@')) {
        # Only write legacy names if they already exist on disk
        Save-Resized -Size $size -OutPath $out
    }
}

$src.Dispose()
$srcStream.Dispose()
Write-Host "`nDone."

param(
  [string]$Source = "$PSScriptRoot\..\assets\icons\genie help Logo.png",
  [string]$OutDir = "$PSScriptRoot\..\assets\icons"
)

Add-Type -AssemblyName System.Drawing

# Load source via memory stream so we never lock the file
$srcBytes  = [System.IO.File]::ReadAllBytes($Source)
$srcStream = New-Object System.IO.MemoryStream (,$srcBytes)
$src       = [System.Drawing.Image]::FromStream($srcStream)

Write-Host "Source: $($src.Width)x$($src.Height)"

# Hand-tuned crop window for the genie help wordmark logo (1254x1254).
# Brand mark sits roughly at x=140..420, y=400..830.
# Use a 580x580 square centered on (~280, ~605) with breathing room.
$cropX    = 10
$cropY    = 380
$cropSize = 450
$bmp      = New-Object System.Drawing.Bitmap $src
Write-Host "Crop: x=$cropX y=$cropY size=$cropSize"

# Produce 1024x1024 maskable master + 1024x1024 standard master
function Save-Square([int]$outSize, [string]$path) {
  $out = New-Object System.Drawing.Bitmap $outSize, $outSize, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($out)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode  = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.SmoothingMode    = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  # Fill black background to match brand
  $bg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 8, 8, 15))
  $g.FillRectangle($bg, 0, 0, $outSize, $outSize)
  $bg.Dispose()
  $destRect = New-Object System.Drawing.Rectangle 0, 0, $outSize, $outSize
  $g.DrawImage($src, $destRect, $cropX, $cropY, $cropSize, $cropSize, [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()
  $out.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $out.Dispose()
  Write-Host "Wrote $path"
}

# Write a fresh standalone master file (not overwriting Source which is locked)
$masterMaskable = Join-Path $OutDir "icon_maskable_512x512.png"
$masterStandard = Join-Path $OutDir "icon_512x512.png"
$masterFull     = Join-Path $OutDir "icon_1024x1024.png"

# Dispose src BEFORE writing to those files (in case any are locked)
$src.Dispose()
$bmp.Dispose()
$srcStream.Dispose()

# Re-read from stream so Save-Square can use $src — actually we need to reload
$srcBytes2 = [System.IO.File]::ReadAllBytes($Source)
$srcStream2 = New-Object System.IO.MemoryStream (,$srcBytes2)
$src = [System.Drawing.Image]::FromStream($srcStream2)

Save-Square -outSize 512 -path $masterMaskable
Save-Square -outSize 512 -path $masterStandard
Save-Square -outSize 1024 -path $masterFull

$src.Dispose()
$srcStream2.Dispose()

Write-Host "Done."

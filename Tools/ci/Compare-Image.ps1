<#
.SYNOPSIS
    Compare a captured frame with a golden image using a perceptual hash and MAE.

.DESCRIPTION
    MMD output is not bit-exact across runs, drivers or window sizes. This
    comparator uses a 64-bit difference hash plus mean absolute error over a
    64x64 grayscale thumbnail. Both metrics are printed; the exit code is 1
    when either exceeds its tolerance.

.PARAMETER Actual
    Captured PNG.

.PARAMETER Golden
    Reference PNG.

.PARAMETER MaxHashDistance
    Maximum Hamming distance for the 64-bit dHash (0..64).

.PARAMETER MaxMae
    Maximum mean absolute error in [0, 1].

.PARAMETER DiffOutput
    Optional path for a 64x64 absolute-difference preview.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Actual,

    [Parameter(Mandatory = $true)]
    [string]$Golden,

    [int]$MaxHashDistance = 10,

    [double]$MaxMae = 0.025,

    [string]$DiffOutput = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

function Resize-Bitmap {
    param(
        [System.Drawing.Bitmap]$Source,
        [int]$Width,
        [int]$Height
    )

    $target = New-Object System.Drawing.Bitmap $Width, $Height
    $graphics = [System.Drawing.Graphics]::FromImage($target)
    try {
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.DrawImage($Source, 0, 0, $Width, $Height)
    }
    finally {
        $graphics.Dispose()
    }

    return $target
}

function Get-Gray {
    param([System.Drawing.Color]$Color)

    return (0.299 * $Color.R + 0.587 * $Color.G + 0.114 * $Color.B)
}

if (-not (Test-Path -LiteralPath $Actual)) { throw "actual image not found: $Actual" }
if (-not (Test-Path -LiteralPath $Golden)) { throw "golden image not found: $Golden" }

$actualBitmap = [System.Drawing.Bitmap]::new((Resolve-Path -LiteralPath $Actual).Path)
$goldenBitmap = [System.Drawing.Bitmap]::new((Resolve-Path -LiteralPath $Golden).Path)

try {
    $actualHashBitmap = Resize-Bitmap -Source $actualBitmap -Width 9 -Height 8
    $goldenHashBitmap = Resize-Bitmap -Source $goldenBitmap -Width 9 -Height 8
    $actualMaeBitmap = Resize-Bitmap -Source $actualBitmap -Width 64 -Height 64
    $goldenMaeBitmap = Resize-Bitmap -Source $goldenBitmap -Width 64 -Height 64

    try {
        [uint64]$actualHash = 0
        [uint64]$goldenHash = 0
        for ($y = 0; $y -lt 8; $y++) {
            for ($x = 0; $x -lt 8; $x++) {
                $actualHash = $actualHash -shl 1
                $goldenHash = $goldenHash -shl 1
                if ((Get-Gray $actualHashBitmap.GetPixel($x, $y)) -gt (Get-Gray $actualHashBitmap.GetPixel($x + 1, $y))) {
                    $actualHash = $actualHash -bor 1
                }
                if ((Get-Gray $goldenHashBitmap.GetPixel($x, $y)) -gt (Get-Gray $goldenHashBitmap.GetPixel($x + 1, $y))) {
                    $goldenHash = $goldenHash -bor 1
                }
            }
        }

        $xor = $actualHash -bxor $goldenHash
        $hashDistance = 0
        while ($xor -ne 0) {
            $hashDistance += [int]($xor -band 1)
            $xor = $xor -shr 1
        }

        $total = 0.0
        $diffBitmap = $null
        $diffGraphics = $null
        if ($DiffOutput) {
            $diffDirectory = Split-Path -Parent $DiffOutput
            if ($diffDirectory -and -not (Test-Path -LiteralPath $diffDirectory)) {
                New-Item -ItemType Directory -Path $diffDirectory -Force | Out-Null
            }
            $diffBitmap = New-Object System.Drawing.Bitmap 64, 64
            $diffGraphics = [System.Drawing.Graphics]::FromImage($diffBitmap)
        }

        try {
            for ($y = 0; $y -lt 64; $y++) {
                for ($x = 0; $x -lt 64; $x++) {
                    $a = Get-Gray $actualMaeBitmap.GetPixel($x, $y)
                    $g = Get-Gray $goldenMaeBitmap.GetPixel($x, $y)
                    $diff = [Math]::Abs($a - $g) / 255.0
                    $total += $diff

                    if ($diffBitmap) {
                        $value = [int][Math]::Min(255, [Math]::Round($diff * 255.0))
                        $diffBitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($value, $value, $value))
                    }
                }
            }
        }
        finally {
            if ($diffGraphics) { $diffGraphics.Dispose() }
            if ($diffBitmap) {
                $diffBitmap.Save($DiffOutput, [System.Drawing.Imaging.ImageFormat]::Png)
                $diffBitmap.Dispose()
            }
        }

        $mae = $total / (64.0 * 64.0)
        $passed = ($hashDistance -le $MaxHashDistance) -and ($mae -le $MaxMae)

        Write-Output ("hashDistance={0} (max {1})" -f $hashDistance, $MaxHashDistance)
        Write-Output ("mae={0:N5} (max {1:N5})" -f $mae, $MaxMae)
        Write-Output ($(if ($passed) { 'PASS' } else { 'FAIL' }))

        if (-not $passed) { exit 1 }
    }
    finally {
        $actualHashBitmap.Dispose()
        $goldenHashBitmap.Dispose()
        $actualMaeBitmap.Dispose()
        $goldenMaeBitmap.Dispose()
    }
}
finally {
    $actualBitmap.Dispose()
    $goldenBitmap.Dispose()
}

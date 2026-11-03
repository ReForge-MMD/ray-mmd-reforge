<#
.SYNOPSIS
    Launch MMD with a project and capture its window to PNG.

.DESCRIPTION
    MMD has no headless render mode, so this script starts the real executable,
    waits for the project to settle, brings the window to the foreground and
    captures it with GDI. Use a fixed window size and a dedicated test machine
    for golden-image comparisons.

.PARAMETER MmdPath
    Path to MikuMikuDance.exe.

.PARAMETER Project
    Optional .pmm project to open.

.PARAMETER Output
    PNG path to write.

.PARAMETER WarmupSeconds
    Time to wait after the window appears before capturing.

.PARAMETER NoClose
    Leave MMD running after the capture.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MmdPath,

    [string]$Project = '',

    [Parameter(Mandatory = $true)]
    [string]$Output,

    [int]$WarmupSeconds = 8,

    [switch]$NoClose
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

if (-not ('RayMmdWin32' -as [type])) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class RayMmdWin32
{
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT
    {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
}
"@
}

function Wait-MainWindow {
    param([System.Diagnostics.Process]$Process, [int]$TimeoutSeconds = 60)

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        $Process.Refresh()
        if ($Process.MainWindowHandle -ne [IntPtr]::Zero) {
            return $Process.MainWindowHandle
        }
        Start-Sleep -Milliseconds 250
    }

    throw "MMD window did not appear within $TimeoutSeconds seconds"
}

if (-not (Test-Path -LiteralPath $MmdPath)) {
    throw "MMD not found: $MmdPath"
}
if ($Project -and -not (Test-Path -LiteralPath $Project)) {
    throw "project not found: $Project"
}

$outputDirectory = Split-Path -Parent $Output
if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$arguments = @()
if ($Project) { $arguments += ('"{0}"' -f (Resolve-Path -LiteralPath $Project).Path) }

$process = Start-Process -FilePath $MmdPath -ArgumentList $arguments -PassThru
try {
    $handle = Wait-MainWindow -Process $process
    [void][RayMmdWin32]::ShowWindow($handle, 9)
    [void][RayMmdWin32]::SetForegroundWindow($handle)
    Start-Sleep -Seconds $WarmupSeconds

    $rect = [RayMmdWin32+RECT]::new()
    if (-not [RayMmdWin32]::GetWindowRect($handle, [ref]$rect)) {
        throw 'GetWindowRect failed'
    }

    $width = $rect.Right - $rect.Left
    $height = $rect.Bottom - $rect.Top
    if ($width -le 0 -or $height -le 0) {
        throw "invalid MMD window size: ${width}x${height}"
    }

    $bitmap = New-Object System.Drawing.Bitmap $width, $height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
        $bitmap.Save($Output, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }

    Write-Output ("Captured {0} ({1}x{2})" -f $Output, $width, $height)
}
finally {
    if (-not $NoClose -and -not $process.HasExited) {
        [void]$process.CloseMainWindow()
        if (-not $process.WaitForExit(10000)) {
            $process.Kill()
        }
    }
}

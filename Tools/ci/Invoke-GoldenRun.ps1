<#
.SYNOPSIS
    Capture MMD scenes and compare them with golden images.

.DESCRIPTION
    Reads a scene manifest (tests/golden/scenes.example.json by default), starts
    MMD for each scene, captures the window, and compares against the golden
    image. Use -Update to accept the current captures as the new goldens.

    This is a self-hosted/GPU check, not a GitHub-hosted CI gate.

.PARAMETER MmdPath
    Path to MikuMikuDance.exe.

.PARAMETER Scenes
    Scene manifest JSON.

.PARAMETER Update
    Replace golden images with the captures.

.PARAMETER Filter
    Only run scene names matching this wildcard.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MmdPath,

    [string]$Scenes = '',

    [switch]$Update,

    [string]$Filter = '*'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$scenePath = if ($Scenes) { $Scenes } else { Join-Path $root 'tests\golden\scenes.example.json' }
if (-not (Test-Path -LiteralPath $scenePath)) { throw "scene manifest not found: $scenePath" }

$captureScript = Join-Path $PSScriptRoot 'Capture-MmdFrame.ps1'
$compareScript = Join-Path $PSScriptRoot 'Compare-Image.ps1'
$actualDirectory = Join-Path $root 'tests\golden\.actual'
if (-not (Test-Path -LiteralPath $actualDirectory)) {
    New-Item -ItemType Directory -Path $actualDirectory -Force | Out-Null
}

$scenes = Get-Content -LiteralPath $scenePath -Raw | ConvertFrom-Json
$selected = @($scenes | Where-Object { $_.name -like $Filter })
if ($selected.Count -eq 0) { throw "no scenes matched filter '$Filter'" }

$failures = [System.Collections.Generic.List[string]]::new()

foreach ($scene in $selected) {
    $project = Join-Path $root $scene.project
    $golden = Join-Path $root $scene.golden
    $actual = Join-Path $actualDirectory ($scene.name + '.png')

    Write-Output ("=== {0} ===" -f $scene.name)
    if (-not (Test-Path -LiteralPath $project)) {
        Write-Output ("  SKIP: project not found: {0}" -f $scene.project)
        $failures.Add($scene.name)
        continue
    }

    $warmup = if ($scene.PSObject.Properties.Name -contains 'warmupSeconds') { $scene.warmupSeconds } else { 8 }
    $captureArgs = @(
        '-NoProfile', '-File', $captureScript,
        '-MmdPath', $MmdPath,
        '-Project', $project,
        '-Output', $actual,
        '-WarmupSeconds', [string]$warmup
    )
    & pwsh @captureArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Output '  FAILED: capture'
        $failures.Add($scene.name)
        continue
    }

    if ($Update) {
        $goldenDirectory = Split-Path -Parent $golden
        if ($goldenDirectory -and -not (Test-Path -LiteralPath $goldenDirectory)) {
            New-Item -ItemType Directory -Path $goldenDirectory -Force | Out-Null
        }
        Copy-Item -LiteralPath $actual -Destination $golden -Force
        Write-Output ("  UPDATED: {0}" -f $scene.golden)
        continue
    }

    if (-not (Test-Path -LiteralPath $golden)) {
        Write-Output ("  SKIP: golden not found: {0} (run with -Update)" -f $scene.golden)
        $failures.Add($scene.name)
        continue
    }

    $diff = Join-Path $actualDirectory ($scene.name + '.diff.png')
    & pwsh -NoProfile -File $compareScript -Actual $actual -Golden $golden -DiffOutput $diff
    if ($LASTEXITCODE -ne 0) {
        Write-Output '  FAILED: image comparison'
        $failures.Add($scene.name)
    }
}

Write-Output ''
Write-Output ("Golden run: {0} scene(s), {1} failure(s)" -f $selected.Count, $failures.Count)
if ($failures.Count -gt 0) {
    Write-Output ("Failed: {0}" -f ($failures -join ', '))
    exit 1
}

<#
.SYNOPSIS
    Measure MMD frame time with PresentMon and print median/p95 statistics.

.DESCRIPTION
    PresentMon is an external Microsoft tool. This wrapper runs it for a fixed
    duration, parses the CSV and reports frame time percentiles. Use the same
    scene, resolution and GPU as the performance budget.

.PARAMETER PresentMon
    Path to PresentMon.exe.

.PARAMETER ProcessName
    Process to capture. Defaults to MikuMikuDance.

.PARAMETER DurationSec
    Capture duration in seconds.

.PARAMETER Style
    PresentMon CLI style: v1 (single dash) or v2 (double dash).

.PARAMETER OutputCsv
    CSV path. Defaults to tests/perf/.last-presentmon.csv.

.PARAMETER ExtraArgs
    Additional PresentMon arguments.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PresentMon,

    [string]$ProcessName = 'MikuMikuDance',

    [int]$DurationSec = 30,

    [ValidateSet('v1', 'v2')]
    [string]$Style = 'v1',

    [string]$OutputCsv = '',

    [string[]]$ExtraArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$csv = if ($OutputCsv) { $OutputCsv } else { Join-Path $root 'tests\perf\.last-presentmon.csv' }
$csvDirectory = Split-Path -Parent $csv
if ($csvDirectory -and -not (Test-Path -LiteralPath $csvDirectory)) {
    New-Item -ItemType Directory -Path $csvDirectory -Force | Out-Null
}
if (Test-Path -LiteralPath $csv) { Remove-Item -LiteralPath $csv -Force }

if (-not (Test-Path -LiteralPath $PresentMon)) {
    throw "PresentMon not found: $PresentMon (download from https://github.com/GameTechDev/PresentMon)"
}

$dash = if ($Style -eq 'v2') { '--' } else { '-' }
$arguments = @(
    "${dash}process_name", $ProcessName,
    "${dash}output_file", $csv,
    "${dash}timed", $DurationSec,
    "${dash}terminate_after_timed"
) + $ExtraArgs

Write-Output ("Running: {0} {1}" -f $PresentMon, ($arguments -join ' '))
& $PresentMon @arguments
if ($LASTEXITCODE -ne 0) { throw "PresentMon exited with code $LASTEXITCODE" }
if (-not (Test-Path -LiteralPath $csv)) { throw "PresentMon did not write $csv" }

$rows = Import-Csv -LiteralPath $csv
if (-not $rows -or $rows.Count -eq 0) { throw 'PresentMon CSV is empty' }

$column = $rows[0].PSObject.Properties.Name |
    Where-Object { $_ -match '^(?i)msBetweenPresents$' } |
    Select-Object -First 1
if (-not $column) {
    throw "CSV has no msBetweenPresents column; found: $($rows[0].PSObject.Properties.Name -join ', ')"
}

$values = @($rows | ForEach-Object { [double]$_.$column })
# Drop the first ~2 seconds to avoid load/compile spikes.
$skip = [Math]::Min(120, [Math]::Max(0, $values.Count - 10))
if ($skip -gt 0) { $values = $values[$skip..($values.Count - 1)] }

$sorted = $values | Sort-Object
$median = $sorted[[int][Math]::Floor($sorted.Count * 0.50)]
$p95 = $sorted[[Math]::Min($sorted.Count - 1, [int][Math]::Floor($sorted.Count * 0.95))]
$mean = ($values | Measure-Object -Average).Average
$fps = 1000.0 / $mean

Write-Output ("frames={0} medianMs={1:N3} p95Ms={2:N3} meanMs={3:N3} fps={4:N2}" -f `
    $values.Count, $median, $p95, $mean, $fps)

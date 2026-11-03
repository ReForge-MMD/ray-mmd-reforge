<#
.SYNOPSIS
    Compile a curated matrix of MME shader entry points with fxc.

.DESCRIPTION
    Uses Tools/ci/hlsl_shim.py to strip MME-only annotations and technique
    blocks, then invokes fxc for each entry point. This validates HLSL syntax,
    macro resolution and ps_3_0/vs_3_0 resource limits without launching MMD.

    The matrix lives in tests/compile/matrix.json. Profiles can override
    #define values, so the same source is compiled under different feature
    combinations.

.PARAMETER Root
    Repository root. Defaults to the parent of this script's tools directory.

.PARAMETER Matrix
    Path to the matrix JSON. Defaults to tests/compile/matrix.json.

.PARAMETER FxcPath
    Explicit fxc.exe path. When omitted, the newest x64 Windows SDK fxc is used.

.PARAMETER Filter
    Only run profiles whose name matches this wildcard.

.EXAMPLE
    pwsh -File Tools/ci/Invoke-ShaderCompile.ps1

.EXAMPLE
    pwsh -File Tools/ci/Invoke-ShaderCompile.ps1 -Filter 'fog_*'
#>
[CmdletBinding()]
param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [string]$Matrix = '',
    [string]$FxcPath = '',
    [string]$Filter = '*'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Find-Fxc {
    param([string]$ExplicitPath)

    if ($ExplicitPath) {
        if (-not (Test-Path -LiteralPath $ExplicitPath)) {
            throw "fxc not found: $ExplicitPath"
        }
        return (Resolve-Path -LiteralPath $ExplicitPath).Path
    }

    $command = Get-Command fxc.exe -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }

    $sdkRoot = 'C:\Program Files (x86)\Windows Kits\10\bin'
    if (Test-Path -LiteralPath $sdkRoot) {
        $candidate = Get-ChildItem -LiteralPath $sdkRoot -Directory |
            Sort-Object Name -Descending |
            ForEach-Object { Join-Path $_.FullName 'x64\fxc.exe' } |
            Where-Object { Test-Path -LiteralPath $_ } |
            Select-Object -First 1

        if ($candidate) { return $candidate }
    }

    throw 'fxc.exe not found. Install the Windows SDK or pass -FxcPath.'
}

function Find-Uv {
    $command = Get-Command uv.exe -ErrorAction SilentlyContinue
    if (-not $command) {
        throw 'uv.exe not found. Install uv (https://docs.astral.sh/uv/) or add it to PATH.'
    }
    return $command.Source
}

$matrixPath = if ($Matrix) { $Matrix } else { Join-Path $Root 'tests\compile\matrix.json' }
if (-not (Test-Path -LiteralPath $matrixPath)) {
    throw "matrix not found: $matrixPath"
}

$fxc = Find-Fxc -ExplicitPath $FxcPath
$uv = Find-Uv
$shim = Join-Path $Root 'Tools\ci\hlsl_shim.py'
$data = Get-Content -LiteralPath $matrixPath -Raw | ConvertFrom-Json

$profiles = @($data.profiles | Where-Object { $_.name -like $Filter })
if ($profiles.Count -eq 0) {
    throw "no profiles matched filter '$Filter'"
}

$failures = [System.Collections.Generic.List[object]]::new()
$total = 0

foreach ($profile in $profiles) {
    Write-Output ("=== profile: {0} ===" -f $profile.name)

    $setArgs = @()
    if ($profile.PSObject.Properties.Name -contains 'set' -and $profile.set) {
        foreach ($property in $profile.set.PSObject.Properties) {
            $setArgs += '--set'
            $setArgs += ('{0}={1}' -f $property.Name, $property.Value)
        }
    }

    $jobArgs = @()
    foreach ($entry in $profile.entries) {
        $total++
        $profileName = if ($entry.PSObject.Properties.Name -contains 'profile') { $entry.profile } else { 'ps_3_0' }
        $jobArgs += '--job'
        $jobArgs += ('{0}|{1}|{2}' -f $entry.source, $entry.entry, $profileName)
        Write-Output ("  {0} ({1})" -f $entry.entry, $profileName)
    }

    $arguments = @(
        'run', '--no-project', $shim,
        '--fxc', $fxc,
        '--root', $Root
    ) + $setArgs + $jobArgs

    $output = & $uv @arguments 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        $failures.Add([pscustomobject]@{
            Profile = $profile.name
            Entry   = '(batch)'
            Source  = '(batch)'
            Output  = ($output | Out-String).Trim()
        })
        Write-Output '    FAILED'
        Write-Output $output
    }
    else {
        Write-Output '    ok'
    }
}

Write-Output ''
Write-Output ("Compiled {0} entry point(s), {1} failure(s)" -f $total, $failures.Count)

if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Output ''
        Write-Output ("--- {0} / {1} / {2} ---" -f $failure.Profile, $failure.Source, $failure.Entry)
        Write-Output $failure.Output
    }
    exit 1
}

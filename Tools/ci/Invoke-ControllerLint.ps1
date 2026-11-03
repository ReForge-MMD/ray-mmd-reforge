<#
.SYNOPSIS
    Validate shader CONTROLOBJECT bindings against controller morph manifests.

.DESCRIPTION
    This is intentionally manifest-driven. Add a JSON file under tests/controls
    for each controller as it gets a stable manifest. The lint reports:
      - bindings that reference a morph not present in the manifest;
      - manifest morphs that no shader reads (advisory).

    Missing manifests are ignored, so the check can be adopted incrementally.

.EXAMPLE
    pwsh -NoProfile -File Tools/ci/Invoke-ControllerLint.ps1
#>
[CmdletBinding()]
param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$manifestDirectory = Join-Path $Root 'tests\controls'
if (-not (Test-Path -LiteralPath $manifestDirectory)) {
    Write-Output 'Controller lint: no manifests found'
    exit 0
}

$shaderFiles = [System.Collections.Generic.List[string]]::new()
$shaderFiles.Add((Join-Path $Root 'ray.fx'))
foreach ($directory in @('Shader', 'Skybox')) {
    $path = Join-Path $Root $directory
    if (-not (Test-Path -LiteralPath $path)) { continue }
    Get-ChildItem -LiteralPath $path -Recurse -File |
        Where-Object { $_.Extension -in @('.fx', '.fxsub') } |
        ForEach-Object { $shaderFiles.Add($_.FullName) }
}

$bindings = [System.Collections.Generic.List[object]]::new()
foreach ($file in $shaderFiles) {
    $text = Get-Content -LiteralPath $file -Raw
    foreach ($match in [regex]::Matches(
        $text,
        'CONTROLOBJECT\s*<\s*string\s+name\s*=\s*"([^"]+)"\s*;\s*string\s+item\s*=\s*"([^"]+)"\s*;')) {
        $bindings.Add([pscustomobject]@{
            File       = $file
            Controller = $match.Groups[1].Value
            Item       = $match.Groups[2].Value
        })
    }
}

$errors = 0
$warnings = 0

foreach ($manifestFile in Get-ChildItem -LiteralPath $manifestDirectory -Filter '*.json') {
    $manifest = Get-Content -LiteralPath $manifestFile.FullName -Raw | ConvertFrom-Json
    $controller = $manifest.controller
    $morphs = @($manifest.morphs)
    $specialItems = @()
    if ($manifest.PSObject.Properties.Name -contains 'specialItems') {
        $specialItems = @($manifest.specialItems)
    }

    $controllerBindings = @($bindings | Where-Object { $_.Controller -like "$controller*" })
    $used = @{}

    foreach ($binding in $controllerBindings) {
        if ($specialItems -contains $binding.Item) { continue }
        if ($morphs -notcontains $binding.Item) {
            $relative = [System.IO.Path]::GetRelativePath($Root, $binding.File)
            Write-Output ("[ERROR] {0}: {1} has no morph '{2}'" -f $relative, $binding.Controller, $binding.Item)
            $errors++
        }
        else {
            $used[$binding.Item] = $true
        }
    }

    foreach ($morph in $morphs) {
        if (-not $used.ContainsKey($morph)) {
            Write-Output ("[WARN] {0}: manifest morph '{1}' is not read by any shader" -f $manifestFile.Name, $morph)
            $warnings++
        }
    }
}

Write-Output ("Controller lint: {0} error(s), {1} warning(s)" -f $errors, $warnings)
if ($errors -gt 0) { exit 1 }

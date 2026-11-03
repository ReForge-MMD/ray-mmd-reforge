<#
.SYNOPSIS
    Run every static shader gate in one command.

.DESCRIPTION
    Executes the shader lint, controller lint and compile matrix in order.
    Stops at the first failing gate. This is the recommended local pre-commit
    and GitHub-hosted CI entry point.

.EXAMPLE
    pwsh -NoProfile -File Tools/ci/Invoke-All.ps1
#>
[CmdletBinding()]
param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [string]$FxcPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$steps = @(
    @{ Name = 'Shader lint'; Script = 'Invoke-ShaderLint.ps1'; Arguments = @() },
    @{ Name = 'Controller lint'; Script = 'Invoke-ControllerLint.ps1'; Arguments = @() },
    @{ Name = 'Compile matrix'; Script = 'Invoke-ShaderCompile.ps1'; Arguments = @() }
)

foreach ($step in $steps) {
    Write-Output ''
    Write-Output ("=== {0} ===" -f $step.Name)
    $scriptPath = Join-Path $PSScriptRoot $step.Script
    $arguments = @('-NoProfile', '-File', $scriptPath, '-Root', $Root) + $step.Arguments
    if ($step.Script -eq 'Invoke-ShaderCompile.ps1' -and $FxcPath) {
        $arguments += @('-FxcPath', $FxcPath)
    }

    & pwsh @arguments
    if ($LASTEXITCODE -ne 0) {
        Write-Output ("FAILED: {0}" -f $step.Name)
        exit $LASTEXITCODE
    }
}

Write-Output ''
Write-Output 'All static shader gates passed.'

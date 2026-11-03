<#
.SYNOPSIS
    Static contract checks for the ray-mmd MME shader tree.

.DESCRIPTION
    Verifies include resolution, entry points, render-target declarations,
    sampler bindings, pass references and a small set of high-confidence
    forbidden patterns. This runs without MMD, D3D9 or a GPU and is intended
    to be a merge-blocking CI gate.

.PARAMETER Root
    Repository root. Defaults to the parent of this script's tools directory.

.PARAMETER FailOnWarning
    Treat warnings as errors.

.EXAMPLE
    pwsh -File Tools/ci/Invoke-ShaderLint.ps1
#>
[CmdletBinding()]
param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [switch]$FailOnWarning
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$findings = [System.Collections.Generic.List[object]]::new()

function Add-Finding {
    param(
        [ValidateSet('Error', 'Warning')]
        [string]$Severity,
        [string]$File,
        [int]$Line,
        [string]$Message
    )

    $findings.Add([pscustomobject]@{
        Severity = $Severity
        File     = $File
        Line     = $Line
        Message  = $Message
    })
}

function Get-LineNumber {
    param([string]$Text, [int]$Index)

    if ($Index -le 0) { return 1 }
    return ($Text.Substring(0, $Index) -split "`n").Count
}

function Get-ShaderFiles {
    param([string]$RepositoryRoot)

    $files = [System.Collections.Generic.List[string]]::new()
    $files.Add((Join-Path $RepositoryRoot 'ray.fx'))

    foreach ($directory in @('Shader', 'Skybox')) {
        $path = Join-Path $RepositoryRoot $directory
        if (-not (Test-Path -LiteralPath $path)) { continue }

        Get-ChildItem -LiteralPath $path -Recurse -File |
            Where-Object { $_.Extension -in @('.fx', '.fxsub') } |
            ForEach-Object { $files.Add($_.FullName) }
    }

    return $files | Sort-Object -Unique
}

$shaderFiles = Get-ShaderFiles -RepositoryRoot $Root
$allText = [System.Text.StringBuilder]::new()
foreach ($file in $shaderFiles) {
    [void]$allText.AppendLine((Get-Content -LiteralPath $file -Raw))
}
$allSource = $allText.ToString()

# ---------------------------------------------------------------------------
# Include resolution
# ---------------------------------------------------------------------------
foreach ($file in $shaderFiles) {
    $text = Get-Content -LiteralPath $file -Raw
    foreach ($match in [regex]::Matches($text, '#\s*include\s+"([^"]+)"')) {
        $include = $match.Groups[1].Value
        $candidates = [System.Collections.Generic.List[string]]::new()
        $directory = Split-Path -Parent $file

        # MME resolves nested includes from the effect root as well as the
        # including file, so try every ancestor directory.
        while ($directory) {
            $candidates.Add((Join-Path $directory $include))
            $parent = Split-Path -Parent $directory
            if (-not $parent -or $parent -eq $directory) { break }
            $directory = $parent
        }
        $candidates.Add((Join-Path $Root $include))

        $resolved = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
        if (-not $resolved) {
            Add-Finding -Severity Error -File $file -Line (Get-LineNumber -Text $text -Index $match.Index) `
                -Message "include not found: $include"
        }
    }
}

# ---------------------------------------------------------------------------
# Entry points and shader model
# ---------------------------------------------------------------------------
foreach ($file in $shaderFiles) {
    $text = Get-Content -LiteralPath $file -Raw
    foreach ($match in [regex]::Matches($text, 'compile\s+(ps|vs)_(\d+)_(\d+)\s+(\w+)\s*\(')) {
        $stage = $match.Groups[1].Value
        $minor = [int]$match.Groups[2].Value
        $major = [int]$match.Groups[3].Value
        $entry = $match.Groups[4].Value

        if ($minor -ne 3 -or $major -ne 0) {
            Add-Finding -Severity Error -File $file -Line (Get-LineNumber -Text $text -Index $match.Index) `
                -Message "unsupported shader profile ${stage}_$minor`_$major (MME requires ${stage}_3_0)"
        }

        $entryPattern = '(?m)\b' + [regex]::Escape($entry) + '\s*\('
        if ($allSource -notmatch $entryPattern) {
            Add-Finding -Severity Error -File $file -Line (Get-LineNumber -Text $text -Index $match.Index) `
                -Message "entry point '$entry' has no definition in the shader tree"
        }
    }
}

# ---------------------------------------------------------------------------
# Render target declarations and references
# ---------------------------------------------------------------------------
$declaredTargets = @{}
$declaredTextures = @{}
foreach ($file in $shaderFiles) {
    $text = Get-Content -LiteralPath $file -Raw

    foreach ($match in [regex]::Matches($text, '(?mi)(?:shared\s+)?texture\s+(\w+)\s*:\s*(?:RENDERCOLORTARGET|OFFSCREENRENDERTARGET|RENDERDEPTHSTENCILTARGET)')) {
        $declaredTargets[$match.Groups[1].Value] = $true
        $declaredTextures[$match.Groups[1].Value] = $true
    }

    foreach ($match in [regex]::Matches($text, '(?m)(?:shared\s+)?texture\s+(\w+)')) {
        $declaredTextures[$match.Groups[1].Value] = $true
    }
}

foreach ($file in $shaderFiles) {
    $text = Get-Content -LiteralPath $file -Raw

    foreach ($match in [regex]::Matches($text, '(?i)RenderColorTarget(?:0|1)?\s*=\s*(\w+)\s*;')) {
        $target = $match.Groups[1].Value
        if (-not $declaredTargets.ContainsKey($target)) {
            Add-Finding -Severity Error -File $file -Line (Get-LineNumber -Text $text -Index $match.Index) `
                -Message "render target '$target' has no RENDERCOLORTARGET declaration"
        }
    }

    foreach ($match in [regex]::Matches($text, '(?i)RenderDepthStencilTarget\s*=\s*(\w+)\s*;')) {
        $target = $match.Groups[1].Value
        if (-not $declaredTargets.ContainsKey($target)) {
            Add-Finding -Severity Error -File $file -Line (Get-LineNumber -Text $text -Index $match.Index) `
                -Message "depth target '$target' has no render-target declaration"
        }
    }

    foreach ($match in [regex]::Matches($text, '(?i)texture\s*=\s*<(\w+)>\s*;')) {
        $texture = $match.Groups[1].Value
        if (-not $declaredTextures.ContainsKey($texture)) {
            Add-Finding -Severity Error -File $file -Line (Get-LineNumber -Text $text -Index $match.Index) `
                -Message "sampler references undeclared texture '$texture'"
        }
    }
}

# ---------------------------------------------------------------------------
# Pass references
# ---------------------------------------------------------------------------
$passDefinitions = @{}
foreach ($file in $shaderFiles) {
    $text = Get-Content -LiteralPath $file -Raw
    foreach ($match in [regex]::Matches($text, '(?m)^\s*pass\s+(\w+)')) {
        $passDefinitions[$match.Groups[1].Value] = $true
    }
}

foreach ($file in $shaderFiles) {
    $text = Get-Content -LiteralPath $file -Raw
    foreach ($stringMatch in [regex]::Matches($text, '"([^"]*)"')) {
        $script = $stringMatch.Groups[1].Value
        foreach ($passMatch in [regex]::Matches($script, 'Pass\s*=\s*(\w+)\s*;')) {
            $pass = $passMatch.Groups[1].Value
            if ($pass -eq 'mmdpass') { continue }
            if (-not $passDefinitions.ContainsKey($pass)) {
                $index = $stringMatch.Index + $stringMatch.Groups[1].Index + $passMatch.Index
                Add-Finding -Severity Error -File $file -Line (Get-LineNumber -Text $text -Index $index) `
                    -Message "script references undefined pass '$pass'"
            }
        }
    }
}

# ---------------------------------------------------------------------------
# High-confidence contract regressions
# ---------------------------------------------------------------------------
$forbiddenPatterns = @(
    @{
        Pattern = 'ViewportSize\.y\s*\*\s*0\.5f\s*\*\s*matProject\._m11'
        Message = 'screen-space radius mixes ViewportSize.y with the X projection scale; use _m22'
    },
    @{
        Pattern = 'lerp\(emissive0,\s*emissive1,\s*MRT8\.a\)'
        Message = 'Gbuffer8.a packs lightModel + alpha; use frac(MRT8.a) or a proper layer flag'
    },
    @{
        Pattern = 'exp\(-\s*0\.002f\s*\*\s*EvaluateCloudDensity'
        Message = 'cloud-shadow coefficient is visually inert; use the calibrated extinction'
    }
)

foreach ($file in $shaderFiles) {
    $text = Get-Content -LiteralPath $file -Raw
    foreach ($rule in $forbiddenPatterns) {
        foreach ($match in [regex]::Matches($text, $rule.Pattern)) {
            Add-Finding -Severity Error -File $file -Line (Get-LineNumber -Text $text -Index $match.Index) `
                -Message $rule.Message
        }
    }
}

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
$errors = @($findings | Where-Object Severity -eq 'Error')
$warnings = @($findings | Where-Object Severity -eq 'Warning')

Write-Output ("Shader lint: {0} files" -f $shaderFiles.Count)
foreach ($finding in ($findings | Sort-Object File, Line, Severity)) {
    $relative = [System.IO.Path]::GetRelativePath($Root, $finding.File)
    Write-Output ("[{0}] {1}:{2}: {3}" -f $finding.Severity.ToUpperInvariant(), $relative, $finding.Line, $finding.Message)
}

Write-Output ("{0} error(s), {1} warning(s)" -f $errors.Count, $warnings.Count)

if ($errors.Count -gt 0 -or ($FailOnWarning -and $warnings.Count -gt 0)) {
    exit 1
}

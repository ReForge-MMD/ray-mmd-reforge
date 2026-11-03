# CI tools

| Script | Purpose | Needs |
| --- | --- | --- |
| `Invoke-All.ps1` | runs lint, controller lint and the compile matrix | PowerShell, uv, Windows SDK |
| `Invoke-ShaderLint.ps1` | includes, entry points, RTs, samplers, passes, contract regressions | PowerShell |
| `Invoke-ControllerLint.ps1` | `CONTROLOBJECT` names vs `tests/controls/*.json` | PowerShell |
| `Invoke-ShaderCompile.ps1` | compile matrix via `hlsl_shim.py` + fxc | uv, Windows SDK |
| `Capture-MmdFrame.ps1` | launch MMD and capture its window | MMD, GPU |
| `Compare-Image.ps1` | dHash + MAE golden comparison | PowerShell, System.Drawing |
| `Invoke-GoldenRun.ps1` | capture + compare a scene manifest | MMD, GPU |
| `Measure-FrameTime.ps1` | PresentMon median/p95 frame time | PresentMon, GPU |

## Quick start

```powershell
# One command for every static gate
pwsh -NoProfile -File Tools/ci/Invoke-All.ps1

# Or run the gates individually
pwsh -NoProfile -File Tools/ci/Invoke-ShaderLint.ps1
pwsh -NoProfile -File Tools/ci/Invoke-ControllerLint.ps1
pwsh -NoProfile -File Tools/ci/Invoke-ShaderCompile.ps1
```

The compile script finds the newest x64 `fxc.exe` in the Windows SDK. Pass
`-FxcPath` if you use a custom SDK. The shim is intentionally separate from
MME semantics: it compiles entry points, it does not run passes.

## Compile matrix

`tests/compile/matrix.json` is the source of truth. Profiles can override
`#define` values:

```json
{
  "name": "fog_analytical",
  "set": { "FOG_ENABLE": "1" },
  "entries": [
    { "source": "ray.fx", "entry": "FogCompositePS" }
  ]
}
```

Add one profile per meaningful feature combination. Keep the total runtime
under a few minutes; use a representative entry point rather than every pass.

## Golden images

MMD has no headless mode. On a dedicated runner:

```powershell
pwsh -File Tools/ci/Invoke-GoldenRun.ps1 `
  -MmdPath 'C:\MMD\MikuMikuDance.exe' `
  -Scenes tests\golden\scenes.json -Update
```

Then run without `-Update` in CI. The comparator is tolerant by design; use
the same resolution, driver and effect set for updates and checks.

## Frame time

```powershell
pwsh -File Tools/ci/Measure-FrameTime.ps1 `
  -PresentMon 'C:\Tools\PresentMon.exe' `
  -ProcessName 'MikuMikuDance' -DurationSec 30
```

Run it on the same scene and resolution as `tests/perf/budgets.json`.

## Adding a controller manifest

Add `tests/controls/<controller>.json`:

```json
{
  "controller": "FogController",
  "specialItems": [ "Position" ],
  "morphs": [ "FogDensity+", "FogDensity-" ]
}
```

The controller lint reports shader bindings to unknown morphs and manifest
morphs that no shader reads.

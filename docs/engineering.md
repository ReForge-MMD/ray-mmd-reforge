# Engineering and verification

This repository is a large D3D9/MME shader codebase with many feature
combinations. The goal of this directory is to keep it verifiable without
turning every change into a manual MMD session.

## Layers

| Layer | Tool | Blocks merges? | Requires GPU/MMD? |
| --- | --- | --- | --- |
| Contracts | `docs/contracts/*.md` | review | no |
| Static lint | `Tools/ci/Invoke-ShaderLint.ps1` | yes | no |
| Compile matrix | `Tools/ci/Invoke-ShaderCompile.ps1` + `tests/compile/matrix.json` | yes | no (fxc only) |
| Controller lint | `Tools/ci/Invoke-ControllerLint.ps1` | yes (errors) | no |
| Golden images | `Tools/ci/Invoke-GoldenRun.ps1` | nightly/manual | yes |
| Frame budget | `Tools/ci/Measure-FrameTime.ps1` | nightly/manual | yes |

## All static gates

```powershell
pwsh -NoProfile -File Tools/ci/Invoke-All.ps1
```

This runs the shader lint, controller lint and compile matrix in order.

## Static lint

```powershell
pwsh -NoProfile -File Tools/ci/Invoke-ShaderLint.ps1
```

Checks include resolution, entry-point definitions, shader-model targets,
render-target declarations, sampler bindings, MME `Pass=` references and a
small set of high-confidence contract regressions. It reads only text files
and is safe to run in CI.

## Compile matrix

```powershell
pwsh -NoProfile -File Tools/ci/Invoke-ShaderCompile.ps1
```

The wrapper locates the newest x64 `fxc.exe` from the Windows SDK and compiles
the curated entry points in `tests/compile/matrix.json`. Profiles can override
`#define` values, so the same source is checked with fog, GI and SSR options
on and off.

`Tools/ci/hlsl_shim.py` creates a temporary copy of the shader tree, strips
MME-only annotations (`CONTROLOBJECT`, `RENDERCOLORTARGET`, technique blocks)
and compiles one entry point at a time. It validates HLSL syntax, macro
resolution and ps_3_0/vs_3_0 limits. It does **not** emulate MME pass routing,
render-target state or model/controller bindings; those are covered by the
lint and the runtime smoke test.

## Runtime checks

MMD has no headless CLI. The runtime scripts therefore take an explicit MMD
path and are intended for a dedicated self-hosted Windows runner:

```powershell
# Capture scenes and compare them with the stored goldens
pwsh -File Tools/ci/Invoke-GoldenRun.ps1 -MmdPath 'C:\MMD\MikuMikuDance.exe' `
    -Scenes 'tests\golden\scenes.json'

# Measure frame time with PresentMon
pwsh -File Tools/ci/Measure-FrameTime.ps1 -PresentMon 'C:\Tools\PresentMon.exe' `
    -ProcessName 'MikuMikuDance' -DurationSec 30
```

Golden comparison uses an average hash plus mean absolute error, so it is
tolerant of driver noise. Update goldens only on the same GPU/driver class
used by the runner.

## Configuration placement

- `ray.conf` — user-facing presets and feature switches.
- `ray_advanced.conf` — numeric constants and internal tuning.

Keep this split: `FOG_QUALITY`, `GI_QUALITY`, `SSR_QUALITY`, `FOG_DEBUG` and
similar switches belong in `ray.conf`; thresholds, bias values and filter
radii belong in `ray_advanced.conf` unless they are explicitly a quality
preset.

## Adding a feature

1. Add the switch to `ray.conf` and the constants to `ray_advanced.conf`.
2. Add the implementation under `Shader/<System>/`.
3. Add the entry point to `tests/compile/matrix.json` with at least the
   default and one "off" profile.
4. Add contract notes if the feature introduces a new unit, direction or
   G-buffer channel.
5. Add a golden scene if the feature changes the visible image.
6. Run lint and compile before the first MMD session.

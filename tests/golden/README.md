# Golden images

Golden captures live here and are produced on the dedicated MMD/GPU runner.
They are not bit-exact references; `Compare-Image.ps1` uses a 64-bit dHash and
a mean absolute error over a 64x64 grayscale thumbnail.

Workflow:

```powershell
# Capture scenes and write/update goldens
pwsh -File tools/ci/Invoke-GoldenRun.ps1 -MmdPath 'C:\MMD\MikuMikuDance.exe' `
    -Scenes tests\golden\scenes.json -Update

# Compare current captures with the stored goldens
pwsh -File tools/ci/Invoke-GoldenRun.ps1 -MmdPath 'C:\MMD\MikuMikuDance.exe' `
    -Scenes tests\golden\scenes.json
```

Use the same resolution, driver and effect set for updates and comparisons.
The runner must be an interactive desktop session (not a Windows service),
because the capture uses GDI `CopyFromScreen`. If MMD is not installed, the
script reports missing projects and exits non-zero; this check is intentionally
not part of the GitHub-hosted workflow.

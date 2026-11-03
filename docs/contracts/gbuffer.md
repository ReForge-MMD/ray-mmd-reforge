# G-buffer contract

Ray-MMD uses eight deferred targets plus a separate material cache. The
opaque and alpha layers share the same encoding, but they are written by
different passes and have different alpha semantics.

## Targets

| Target | Texture | Format | Written by | Semantics |
| --- | --- | --- | --- | --- |
| Gbuffer1 | `MaterialMap` | A8R8G8B8 | material cache pass | material lookup / editor data |
| Gbuffer2 | `Gbuffer2RT` | A8R8G8B8 | `MaterialPS` | opaque albedo, smoothness |
| Gbuffer3 | `Gbuffer3RT` | A8R8G8B8 | `MaterialPS` | opaque specular / custom data |
| Gbuffer4 | `Gbuffer4RT` | A16B16G16R16F | `MaterialPS` | opaque depth, emissive, visibility, light model |
| Gbuffer5 | `Gbuffer5RT` | A8R8G8B8 | `Material2PS` | alpha-layer albedo, smoothness |
| Gbuffer6 | `Gbuffer6RT` | A8R8G8B8 | `Material2PS` | alpha-layer normal, custom data |
| Gbuffer7 | `Gbuffer7RT` | A8R8G8B8 | `Material2PS` | alpha-layer specular / emissive |
| Gbuffer8 | `Gbuffer8RT` | A16B16G16R16F | `Material2PS` | alpha-layer depth, emissive, visibility, light model |

`Gbuffer4`/`Gbuffer8` store the same four components
(`EncodeGbuffer`, `Materials/material_common_2.0.fxsub:1167`):

- `.x`: linear **view-space Z** depth.
- `.y`: emissive intensity (or packed SSS UV on opaque skin).
- `.z`: material visibility / occlusion.
- `.w`: `lightModel + alpha * MAX_FRACTIONAL_8_BIT`.

Decode the light model with `floor(.w)` and the alpha fraction with
`frac(.w) / MAX_FRACTIONAL_8_BIT` (`Shader/Core/gbuffer.fxsub`). Do not use
`.w` directly as a 0..1 blend weight: it also contains the shading model.

## Layer rules

- `MaterialPS` writes the opaque layer and sets `material.alpha = 1`.
- `Material2PS` writes the alpha layer. For opaque materials it sets
  `material.alpha = 0`; for alpha-tested/blended materials it stores the
  real alpha. The alpha layer still contains geometry data (depth, normal,
  albedo) for opaque surfaces, so consumers may read colour/depth from
  `Gbuffer5..8`, but must use the decoded alpha fraction when they need to
  know whether the alpha layer is actually present.
- `ShadingOpacityPS` reads `Gbuffer1..4`; `ShadingTransparentPS` reads
  `Gbuffer5..8`.
- Screen-space effects that trace the visible scene (`SSGI`, `SSPT`, `SSR`)
  read `Gbuffer5..8`, because that layer is populated for every visible
  surface and carries the final alpha state. This is intentional.

## Depth

All depth values in `Gbuffer4.x` / `Gbuffer8.x` are **view-space Z**, not
Euclidean ray distance. Convert before comparing with raymarch distances:

```hlsl
float rayDistance = viewZ / max(viewRay.z, 1e-4f);
```

Do not mix the two units in a single integration; see `units.md`.

## Normals

`Gbuffer2.xyz` (opaque) and `Gbuffer6.xyz` (alpha layer) are encoded with
`EncodeNormal`/`DecodeNormal` (`Shader/Core/gbuffer.fxsub`). Always decode
before lighting or bilateral weighting.

## Adding a new layer

If a new target is added, update:

1. `Shader/Core/textures.fxsub` (texture + sampler).
2. The material pass script (`RenderColorTarget3`, etc.).
3. `DecodeGbuffer` / `EncodeGbuffer` if the meaning of a channel changes.
4. `docs/contracts/gbuffer.md`.
5. `Tools/ci/Invoke-ShaderLint.ps1` if the target needs a new declaration
   pattern.

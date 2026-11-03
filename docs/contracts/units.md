# Units and coordinate spaces

Most shader bugs in this project come from mixing two units that look similar
but are not interchangeable.

## Depth units

| Name | Meaning | Where |
| --- | --- | --- |
| view-space Z | distance along the camera forward axis | `Gbuffer4.x`, `Gbuffer8.x`, `GetViewPosition` |
| ray distance | Euclidean length along a normalized view ray | raymarch loops, fog, SSR/GI travel distances |
| NDC depth | clip-space Z divided by W | projection code, SSR depth compare |

Convert once and keep the unit in the variable name:

```hlsl
float rayDistance = viewZ / max(viewRay.z, 1e-4f);
```

At the screen center `viewRay.z == 1`, so the values coincide. At the edges
they differ by up to ~10% at a 40-degree FOV. Never compare a `sceneDepth`
from the G-buffer against a raymarch `t` without converting.

Fog-specific values:

- `mFogRaymarchMaxDistance = 250` is a **ray distance**.
- `mFogStartDistanceDefault = 5` is a **ray distance**.
- `mPSSMDepthZMax = 4000` is a normalized **light-space depth** divisor.
- `mPSSMCascadeZMax = 400` is a camera **view-space Z** boundary.

## World scale

MMD world units are roughly centimeters at character scale. The project is
calibrated around a character height of ~15-20 units:

- fog density: `1 / world unit`
- fog heights: world units
- AO radii: world units, projected to screen pixels with the Y projection
  scale (`matProject._m22`), not the X scale
- sun angular radius: radians (`mSunAngularRadius`)
- cloud layer: `cloudTop = 9.6 * mUnitDistance`, where `mUnitDistance` is the
  skybox scale constant

## Screen-space units

- `ViewportSize` is the current viewport in pixels.
- `ViewportOffset = 0.5 / ViewportSize`.
- `ViewportOffset2 = 1.0 / ViewportSize`.
- A render target with `ViewportRatio = {0.5, 0.5}` is half resolution; its
  texel size is `2 * ViewportOffset2`, not `ViewportOffset2`.
- `matProject._m11` is the X projection scale; `_m22` is the Y scale. When
  converting a world radius to pixels using `ViewportSize.y`, use `_m22`.

## Alpha packing

`Gbuffer4.w` / `Gbuffer8.w` contain `lightModel + alpha * (255/256)`. Decode:

```hlsl
int lightModel = (int)floor(buffer.w);
float alpha = frac(buffer.w) / MAX_FRACTIONAL_8_BIT;
```

`frac(buffer.w)` is **not** a generic layer-presence flag; it is the encoded
material alpha. For a layer-presence test use the decoded alpha or the
appropriate depth channel.

# Known limitations

This file records approximations and test gaps that are intentional, known or
currently unverified. It is not a bug list; use the issue tracker for that.

## Rendering approximations

- **Screen-space GI/SSR**: both are limited to the visible G-buffer and cannot
  see off-screen geometry. Rays that leave the screen fall back to the sky or
  fade out.
- **SSGI/SSPT filtering**: the spatial denoisers trade noise for softness;
  aggressive settings can still produce speckle or light bleeding on thin
  geometry.
- **Cloud shadows for godrays**: `SunOcclusionMap` is a 1x1 single-sample
  transmittance. It dims the whole fog volume when clouds cover the sun; it
  does not produce per-gap shafts. A 2D light-space cloud shadow map would be
  needed for that.
- **Volumetric fog**: the raymarch is limited to `mFogRaymarchMaxDistance`
  (250 world units); beyond that the analytical far-field model is used.
  `FOG_QUALITY` controls the step count and blur taps.
- **Transparent surfaces**: fog and other depth-driven effects use the nearest
  G-buffer depth. A nearly transparent surface occludes fog behind it instead
  of attenuating it as a transmittance layer.
- **SSR roughness**: reflections are prefiltered from a four-level radiance
  pyramid, not from a true GGX convolution. Very rough reflections are an
  approximation.

## Verification gaps

- There is no MMD headless mode. Golden and performance checks need a
  dedicated Windows GPU runner with MMD and a fixed driver/resolution.
- The fxc shim validates HLSL and ps_3_0/vs_3_0 limits, but not MME pass
  routing, `CONTROLOBJECT` bindings, `DefaultEffect` routing or render-target
  state. A compile pass is not a runtime pass.
- The static lint is intentionally conservative; it does not prove that a
  render target is not sampled while bound, nor that every `MMDPass` variant
  exists.
- Golden images are compared with a perceptual hash and a mean absolute error
  tolerance. They are not a pixel-exact regression gate.
- Performance budgets are measured with PresentMon on a fixed scene; they are
  not a per-pass GPU profile.

## Configuration caveats

- `FOG_CLOUD_SHADOW_ENABLE` assumes a cloud skybox that writes
  `SunOcclusionMap`. Other skyboxes leave the 1x1 target at its white clear
  value, which means unshadowed godrays.
- `FOG_QUALITY 3` (48 steps) and `SSR_QUALITY 4` (512 depth taps) are heavy on
  integrated GPUs. Lower profiles exist for a reason.
- `GI_FILTER_RADIUS` and `GI_PREFILTER_RADIUS` are compile-time knobs; changing
  them requires an MME refresh.
- `CutoffDistance` in the fog controller is clamped by the volumetric raymarch
  to `mFogRaymarchMaxDistance`; below that boundary it only affects the
  analytical far field.

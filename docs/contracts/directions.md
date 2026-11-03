# Direction and matrix conventions

Ray-MMD uses row-vector matrices (`mul(vector, matrix)`) and MMD's light
direction convention. Mixing these up produces inverted lighting, backlit
clouds or reflections from the wrong side of a surface.

## Light

- `SunDirection` is the MMD directional-light vector **from the light toward
  the scene**. For a sun above the horizon, `SunDirection.y < 0`.
- The vector **toward** the sun is `-SunDirection`.
- `SunColor` is the light colour; `mSunIntensity` / `PBR` scales live in the
  material and fog code.

Examples:

```hlsl
float3 L = -SunDirection;              // surface shading
float3 sunDir = -SunDirection;         // cloud scattering / transmittance
float3 moonDir = normalize(-SunDirection); // night clouds
```

The cloud integration is a special case: `ComputeCloudsInscattering` receives
MMD's `SunDirection`, but passes `-L` to `ComputeCloudsInsctrIntegral`, which
therefore already works in the "toward the sun" space. Do not negate it again
inside that function.

## Camera

- `CameraDirection` is the camera forward vector (from camera to scene).
- `CameraPosition` is the camera world position.
- A reconstructed view ray points forward (`viewRay.z > 0`).
- `reflect(-V, N)` is used for specular reflection; `V` points from the
  surface toward the camera.

## Matrices

Ray-MMD uses row-vector conventions:

```hlsl
float4 clip = mul(float4(worldPos, 1.0), matViewProject);
float3 viewPos = mul(clip.xyz / clip.w, matProjectInverse);
```

- `matProject._m11` is the X scale (1 / (tan(fov/2) * aspect)).
- `matProject._m22` is the Y scale (1 / tan(fov/2)).
- `matProjectInverse._43` is used by `GetProjConstant` to reconstruct rays.
- `matLightProjectFromCameraView` maps camera-view space to light clip space;
  it already includes the view-to-world transform.

## Artifacts caused by convention mistakes

- Sun disk visible but surfaces unlit: `L` negated twice.
- Silver lining on the wrong side of clouds: cloud phase/transmittance using
  `SunDirection` instead of `-SunDirection`.
- Reflections upside down: Y flip applied twice in UV space.
- AO/reflection radius scaling with aspect ratio: using `_m11` with
  `ViewportSize.y`.

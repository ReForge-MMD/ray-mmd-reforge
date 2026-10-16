# Planar Reflections

Ray-MMD ReForge can capture one real-time planar reflection and composite it into the deferred PBR specular result. The planar image takes priority where capture data is valid; SSR and IBL remain visible outside its coverage.

## Enable and position the plane

1. In `ray.conf`, set `PLANAR_REFLECTION_QUALITY` to `1` for a half-resolution capture or `2` for full resolution. The default is `1`; use `0` to disable the extra scene render.
2. Refresh all MME effects.
3. Use the `ray.x` accessory transform to position the plane. Its local **+Y** axis is the plane normal; the default origin and orientation are a horizontal plane at world `Y = 0`. Scale `ray.x` to adjust the finite receiving area.
4. Assign a reflective ray material to the receiving surface. Increase smoothness and ensure its SSR receiver visibility is not zero.
5. In the `PlanarReflectionMap` MME tab, keep objects that should appear in the reflection enabled and remove excluded objects.

Plane proximity, local X/Z half-extents and edge fade, angle, roughness fade, blur radius, intensity, and capture-plane bias are tuned in `ray_advanced.conf` (`mPlanarReflection*`). The configured half-extents are multiplied by the accessory's X/Z scale.

## Pipeline and limits

- `PlanarReflectionMap` is an HDR `OFFSCREENRENDERTARGET`; its default route hides ray.x, skyboxes, controllers, editors, fog controllers, and volumetric controllers, then draws scene geometry through `PlanarReflectionCapture.fx`. Skipping skybox geometry avoids replacing ray's IBL sky contribution with untextured MMD material color.
- The capture reflects geometry around the ray.x plane, reverses projected X to restore winding, and clips the opposite side of the plane and a small self-intersection bias.
- The deferred resolve projects receiver pixels into the capture, applies PBR specular/Fresnel, a five-tap roughness blur, plane-distance and facing fades, and the existing SSR receiver mask. SSR and IBL are retained wherever the capture has no valid pixel.
- The capture material is a lightweight MMD forward approximation using diffuse/sphere/toon textures and direct/ambient material lighting. It does not recursively run ray's deferred PBR, GI, post-processing, or other planar captures. Only one plane is supported per ray.x instance.
- MME / Direct3D 9 Shader Model 3.0 is required. Full-resolution capture redraws scene geometry every frame and is the more expensive setting.

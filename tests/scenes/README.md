# Golden scenes

Create fixed `.pmm` projects here and reference them from
`tests/golden/scenes.json`. A scene must be deterministic:

- fixed camera keyframe (no camera motion at the captured frame),
- fixed controller morph values,
- fixed resolution and window size,
- no random particles or physics that change between runs,
- the same skybox and effect set across runs.

Recommended coverage:

| Scene | Systems |
| --- | --- |
| `character_day` | skin/SSSS, hair, shadows, AO, default lighting |
| `glass_water` | SSR, refraction, transparency, caustics |
| `gi_room` | SSGI/SSPT, emissive surfaces, multi-bounce |
| `fog_night` | volumetric fog, godrays, night clouds, moon |
| `skin_closeup` | skin SSSS, eye shading, specular |

The `.pmm` files are intentionally not committed in this repository. Add them
on the dedicated MMD test machine and copy `scenes.example.json` to
`scenes.json` with the real paths.

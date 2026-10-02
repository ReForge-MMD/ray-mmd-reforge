# Toon materials

Cel-shaded duplicates of every material family in `Materials/`. Each file is its
non-toon counterpart with `CUSTOM_ENABLE 8` (`SHADINGMODELID_CEL`) and tuned
`customA`/`customB`:

- `customA` — shadow terminator threshold (0..1)
- `customB` — shadow color

Requires `TOON_ENABLE 1` (or 2) in ray.conf. Assign to a PMX material slot in MME
like any other material fx; albedo/alpha are pulled from the model automatically.

## Hierarchy

```
Materials/Toon/
├── material_toon.fx          # base cel template
├── material_tonebased.fx     # smooth ramp variant (SHADINGMODELID_TONEBASED, CUSTOM_ENABLE 9)
├── Auto-Normal/              # screen-space normal derivatives, cel-shaded (hq / ultra)
├── ClearCoat/
├── Cloth/                    # incl. silk, velvet, black_coat, white
├── Emissive/                 # BodyLine, Rainbow, Fixed Color (x1/x2/x4), Blink variants
├── Eye/                      # eye, eye_anime (CUSTOM_ENABLE 10: unshadowed eye model)
├── Foliage/                  # grass, leaves_tree, palm, vines
├── Hair/
│   ├── material_hair*.fx     # hair, procedural, sss, anisotropy variants
│   ├── Procedural Bonus/     # 13 super shine
│   ├── Procedural Metallic/  # Coarse / Fine / Very Fine x low-medium-high shine
│   └── Procedural Silky/     # semi-matte .. very shiny
├── Metallic/                 # flat ingot rough/smooth/worn, ingot bricks (6 metals each)
├── Programmable/
│   ├── Water/                # legacy self-contained folder, copied verbatim (no cel flip)
│   └── Wetness/              # legacy self-contained folder, copied verbatim (no cel flip)
├── Skin/
│   ├── Human/, TDA/          # body/face variants
│   └── material_skin*.fx     # skin, beige/dark, melanoderm
├── Subsurface/               # jade_white, lampshade, marble
├── Transparent/              # glass, glasses, plastic, force_*
└── Video/                    # screen, screen_emissive, screen_led
```

Not duplicated: `Editor/` (per-request skip), top-level `material_mirror.fx` /
`material_skybox.fx`.

## Default shadow colors

| Family | customA | customB |
| --- | --- | --- |
| Skin / body / TDA | 0.55 | warm `float3(0.92, 0.78, 0.75)` |
| Hair (incl. procedural) | 0.45 | cool lavender `float3(0.55, 0.50, 0.78)` |
| Eye (`CUSTOM_ENABLE 10`) | 0.85 (cornea smoothness) | — (unshadowed eye model) |
| Cloth | 0.50 | cool gray `float3(0.62, 0.62, 0.72)` |
| Foliage | 0.50 | deep green `float3(0.28, 0.42, 0.18)` |
| everything else | 0.50 | lavender `float3(0.70, 0.60, 0.75)` |

*Note on Eye*: Eye materials (`Eye/`) use `CUSTOM_ENABLE 10` (`SHADINGMODELID_EYE`) instead of cel shading. They bypass eyelid/hair shadows, SSAO/SSDO, and terminator falloff while preserving corneal clearcoat highlights, without false emissive glow in darkness.

## Look grading

Global knobs live in ray.conf below `TOON_ENABLE`, ported from the community toon shaders:

- `TOON_SHADOW_MUL` / `TOON_SHADOW_ADD` / `TOON_SHADOW_HUE` — grade every shadow color (PAToon2 影RGB/HSV, M4Toon2 影乗算/加算/色相シフト)
- `TOON_SHADOW_WARMTH` — luminance-preserving warm push on shadows (T_ToonShader skin mode)
- `TOON_AUTOTINT_*` — auto-tint shadows over low-saturation albedo (M4Toon2 低彩度影着色)
- `TOON_SELF_POWER_SHADOW` — derive shadow color from albedo when a material defines none (Jashin Toon)
- `TOON_RIM_STRENGTH` / `TOON_RIM_POWER` — rim light folded into the terminator before banding

Note: emissive templates stay emissive while the pmx has emissive color
(`GetLightMode` prioritizes it); cel shading takes over once it's zeroed.

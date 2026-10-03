# Tonal Skin Materials

Calibrated 5×5 tonal skin matrix presets for anime, stylized, and semi-realistic characters in **Ray-MMD ReForge**.

These presets adjust the model's base skin texture through calibrated albedo scaling while providing realistic subsurface scattering (SSS), micro-surface pore detail, and tuned specular responses.

---

## Directory Hierarchy

Organized by **Finish** (Matte / Glossy), then by **Undertone** (01..05), containing exactly 5 luminance levels per folder:

```
Materials/Skin/Tonal/
├── Matte/                              # Soft natural matte finish (smoothness = 0.45, specular = 0.35)
│   ├── 01_Neutral/                     # Unbiased skin tone (1_bright .. 5_dark)
│   ├── 02_Warm_Ivory/                  # Warm cream/ivory tone
│   ├── 03_Cool_Lavender/               # Porcelain cool pink/violet tone
│   ├── 04_Rosy_Peach/                  # Flushed peach/blush tone
│   └── 05_Pale_Olive/                  # Light pale olive neutralizer
├── Glossy/                             # Moisturized glossy finish (smoothness = 0.60, specular = 0.35)
│   ├── 01_Neutral/
│   ├── 02_Warm_Ivory/
│   ├── 03_Cool_Lavender/
│   ├── 04_Rosy_Peach/
│   └── 05_Pale_Olive/
└── README.md
```

---

## Undertone Matrix (Hue Calibration)

Each undertone folder adjusts the temperature and color balance of the model's diffuse texture:

| Folder | Undertone | RGB Factor | Visual Description & Best Use |
| :--- | :--- | :---: | :--- |
| **`01_Neutral`** | `neutral` | `(255, 255, 255)` | **Pure White / Unbiased**. Preserves the exact color temperature of the model texture, only modifying luminance. |
| **`02_Warm_Ivory`** | `warm_ivory` | `(255, 255, 220)` | **Warm Ivory**. Subtle yellow/cream warmth with reduced blue channel. Ideal for natural warm Asian or golden skin tones. |
| **`03_Cool_Lavender`** | `cool_lavender` | `(280, 220, 255)` | **Cool Lavender**. Porcelain pink-violet tone with reduced green channel. Neutralizes muddy yellow textures, providing pale anime skin. |
| **`04_Rosy_Peach`** | `rosy_peach` | `(350, 210, 230)` | **Rosy Peach**. Warm flush with boosted red channel. Adds healthy blood flow, facial blush, and warmth to shoulders/joints. |
| **`05_Pale_Olive`** | `pale_olive` | `(280, 300, 230)` | **Pale Olive**. Light green-cream neutralizer. Counteracts overly red/saturated model textures for a clean muted complexion. |

---

## Luminance Levels (Value / Brightness)

Inside each undertone folder, files are sorted by brightness divisor:

| Level Suffix | Divisor | Texture Multiplier | Description |
| :--- | :---: | :---: | :--- |
| **`1_bright`** | `/ 255.0` | **100.0%** | Full base brightness of the model texture. |
| **`2_medium_bright`** | `/ 300.0` | **85.0%** | Subtle darkening to prevent blown-out highlights under bright lighting. |
| **`3_medium`** | `/ 400.0` | **63.8%** | Medium tone density for balanced cinematic contrast. |
| **`4_medium_dark`** | `/ 500.0` | **51.0%** | Soft tan / sun-kissed bronzed complexion. |
| **`5_dark`** | `/ 600.0` | **42.5%** | Deep tan / dark bronze skin tone. |

---

## Physical Shading Parameters (PBR Standards)

All presets adhere to the **Ray-MMD ReForge** physically based rendering pipeline:

- **Subsurface Scattering (CUSTOM_ENABLE 1)**:
  - `customA = 0.6`: Curvature and diffuse scattering radius.
  - `customB = float3(238, 104, 94) / 255.0`: Clean-room sRGB transmittance color (UE5 standard skin SSS profile). Internal `srgb2linear()` conversion handled automatically by `material_common_2.0.fxsub`.
- **Micro-Surface Normal Detail**:
  - `#define NORMAL_SUB_MAP_FILE "../../../../_MaterialMap/skin.png"`
  - `normalSubMapScale = 1.5`
  - `normalSubMapLoopNum = 80.0`
- **Specular**:
  - `specular = 0.35` (dielectric biological skin reflectance, ~3.5% F0).
- **Albedo Pipeline**:
  - `#define ALBEDO_MAP_FROM 3` (fetches model's PMX diffuse texture).
  - `#define ALBEDO_MAP_APPLY_SCALE 1` (multiplies texture by calibrated tonal vector).

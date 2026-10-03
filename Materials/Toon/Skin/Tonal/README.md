# Toon Tonal Skin Materials (Cel-Shaded)

Cel-shaded duplicates of the `Materials/Skin/Tonal/` matrix for **Ray-MMD ReForge**.

Each file is configured with `CUSTOM_ENABLE 8` (`SHADINGMODELID_CEL`) for sharp anime cel-shading, paired with calibrated albedo scaling, pore normal detail, and custom cel shadow parameters:
- `customA = 0.75` (shadow terminator threshold)
- `customB = float3(0.92, 0.78, 0.75)` (warm cel shadow color)

Requires `TOON_ENABLE 1` (or 2) in `ray.conf`.

---

## Directory Hierarchy

Organized by **Finish** (Matte / Glossy), then by **Undertone** (01..05), containing exactly 5 luminance levels per folder:

```
Materials/Toon/Skin/Tonal/
├── Matte/                              # Soft natural matte cel-shaded finish (smoothness = 0.45, specular = 0.35)
│   ├── 01_Neutral/                     # Unbiased skin tone (1_bright .. 5_dark)
│   ├── 02_Warm_Ivory/                  # Warm cream/ivory tone
│   ├── 03_Cool_Lavender/               # Porcelain cool pink/violet tone
│   ├── 04_Rosy_Peach/                  # Flushed peach/blush tone
│   └── 05_Pale_Olive/                  # Light pale olive neutralizer
├── Glossy/                             # Moisturized glossy cel-shaded finish (smoothness = 0.60, specular = 0.35)
│   ├── 01_Neutral/
│   ├── 02_Warm_Ivory/
│   ├── 03_Cool_Lavender/
│   ├── 04_Rosy_Peach/
│   └── 05_Pale_Olive/
└── README.md
```

---

## Undertone Matrix (Hue Calibration)

| Folder | Undertone | RGB Factor | Visual Description & Best Use |
| :--- | :--- | :---: | :--- |
| **`01_Neutral`** | `neutral` | `(255, 255, 255)` | **Pure White / Unbiased**. Preserves model's original texture balance in cel-shading. |
| **`02_Warm_Ivory`** | `warm_ivory` | `(255, 255, 220)` | **Warm Ivory**. Subtle cream warmth. Ideal for natural warm Asian or golden anime skin tones. |
| **`03_Cool_Lavender`** | `cool_lavender` | `(280, 220, 255)` | **Cool Lavender**. Porcelain pink-violet tone. Neutralizes yellow tints for pale anime heroines. |
| **`04_Rosy_Peach`** | `rosy_peach` | `(350, 210, 230)` | **Rosy Peach**. Warm flush with boosted red channel. Adds vibrant anime blush and healthy blood flow. |
| **`05_Pale_Olive`** | `pale_olive` | `(280, 300, 230)` | **Pale Olive**. Light green-cream neutralizer. Counteracts overly red/saturated textures. |

---

## Luminance Levels (Value / Brightness)

| Level Suffix | Divisor | Texture Multiplier | Description |
| :--- | :---: | :---: | :--- |
| **`1_bright`** | `/ 255.0` | **100.0%** | Full base brightness of the model texture. |
| **`2_medium_bright`** | `/ 300.0` | **85.0%** | Subtle darkening to balance bright cel-shaded stages. |
| **`3_medium`** | `/ 400.0` | **63.8%** | Medium tone density for high-contrast anime rendering. |
| **`4_medium_dark`** | `/ 500.0` | **51.0%** | Soft tan / sun-kissed cel skin. |
| **`5_dark`** | `/ 600.0` | **42.5%** | Deep tan / dark anime skin. |

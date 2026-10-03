# Toon Textured Hair Materials (Cel-Shaded)

Cel-shaded duplicates of the `Materials/Hair/Textured/` suite for **Ray-MMD ReForge**.

Each file combines the clean-room strand normal map (`Materials/Toon/_MaterialMap/hair.png`) with cel-shading (`CUSTOM_ENABLE 8`) and tuned lavender-tinted hair shadows:
- `customA = 0.75` (shadow terminator threshold)
- `customB = float3(0.55, 0.50, 0.78)` (cool lavender hair shadow color)

Requires `TOON_ENABLE 1` (or 2) in `ray.conf`.

---

## Directory Hierarchy

```
Materials/Toon/Hair/Textured/
├── 1. Silky/
│   ├── hair_silky_matte.fx / _realistic.fx
│   ├── hair_silky_natural.fx / _realistic.fx
│   └── hair_silky_gloss.fx / _realistic.fx
├── 2. Clustered/
│   ├── hair_clustered_low_shine.fx / _realistic.fx
│   ├── hair_clustered_med_shine.fx / _realistic.fx
│   └── hair_clustered_high_shine.fx / _realistic.fx
├── 3. Fine_Strands/
│   ├── hair_fine_low_shine.fx / _realistic.fx
│   ├── hair_fine_med_shine.fx / _realistic.fx
│   └── hair_fine_high_shine.fx / _realistic.fx
├── 4. Anime_Anisotropic/
│   ├── hair_anime_soft.fx / _realistic.fx
│   └── hair_anime_vibrant.fx / _realistic.fx
└── README.md
```

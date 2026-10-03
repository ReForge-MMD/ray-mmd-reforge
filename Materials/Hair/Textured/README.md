# Textured Hair Materials

Realistic and stylized hair material presets built upon the clean-room anisotropic normal map (`Materials/_MaterialMap/hair.png`).

Unlike mathematical procedural hair which generates highlights via analytical sine hashes, **Textured Hair** utilizes a multi-scale baked tangent-space strand normal map combined with Kajiya-Kay / Marschner anisotropic BRDF (`CUSTOM_ENABLE 3`).

---

## Directory Hierarchy

```
Materials/Hair/Textured/
├── 1. Silky/                  # Soft natural flowing hair with smooth anisotropic sheen
│   ├── hair_silky_matte.fx / _realistic.fx
│   ├── hair_silky_natural.fx / _realistic.fx
│   └── hair_silky_gloss.fx / _realistic.fx
├── 2. Clustered/              # Pronounced thick locks and clumps with deep strand grooves (loop 8x-10x)
│   ├── hair_clustered_low_shine.fx / _realistic.fx
│   ├── hair_clustered_med_shine.fx / _realistic.fx
│   └── hair_clustered_high_shine.fx / _realistic.fx
├── 3. Fine_Strands/           # High-density individual micro-fibers (dense loop 25x-30x)
│   ├── hair_fine_low_shine.fx / _realistic.fx
│   ├── hair_fine_med_shine.fx / _realistic.fx
│   └── hair_fine_high_shine.fx / _realistic.fx
├── 4. Anime_Anisotropic/      # Stylized anime highlights (Angel Ring / 天使の輪)
│   ├── hair_anime_soft.fx / _realistic.fx
│   └── hair_anime_vibrant.fx / _realistic.fx
└── README.md
```

---

## Variants: Standard vs `_realistic`

Each preset is provided in two variants:
- **`[name].fx`**: Standard alpha blend for opaque or solid hair meshes.
- **`[name]_realistic.fx`**: Includes Dave Hoskins `HASHED_ALPHA_TEST_ENABLE 1` band-limited stochastic alpha cutout, eliminating sorting artifacts, halos, and staircasing on layered polygon hair cards.

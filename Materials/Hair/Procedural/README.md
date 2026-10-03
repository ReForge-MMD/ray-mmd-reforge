# Procedural Hair Materials

Mathematical procedural hair material presets for **Ray-MMD ReForge**.

These presets synthesize fine anisotropic hair highlights on-the-fly using procedural trigonometric hashes (`PROCEDURAL_HAIR 1`), eliminating texture memory overhead while producing sharp, flicker-free specular responses.

---

## Directory Hierarchy

```
Materials/Hair/Procedural/
├── 1. Silky/                  # Silky anisotropic hair with shift map (matte / natural / gloss)
│   ├── hair_procedural_silky_matte.fx / _realistic.fx
│   ├── hair_procedural_silky_natural.fx / _realistic.fx
│   ├── hair_procedural_silky_gloss.fx / _realistic.fx
│   └── shift4.png
├── 2. Metallic_Coarse/        # Coarse procedural hair with broad highlights (1x normal loop)
│   ├── hair_procedural_metallic_coarse_low.fx / _realistic.fx
│   ├── hair_procedural_metallic_coarse_med.fx / _realistic.fx
│   └── hair_procedural_metallic_coarse_high.fx / _realistic.fx
├── 3. Metallic_Fine/          # Fine procedural hair with dense highlights (2x normal loop)
│   ├── hair_procedural_metallic_fine_low.fx / _realistic.fx
│   ├── hair_procedural_metallic_fine_med.fx / _realistic.fx
│   └── hair_procedural_metallic_fine_high.fx / _realistic.fx
├── 4. Metallic_Very_Fine/     # Micro-fine procedural hair highlights (3x normal loop)
│   ├── hair_procedural_metallic_vfine_low.fx / _realistic.fx
│   ├── hair_procedural_metallic_vfine_med.fx / _realistic.fx
│   └── hair_procedural_metallic_vfine_high.fx / _realistic.fx
├── 5. Super_Shine/            # Maximum anime specular highlight (smoothness 0.90)
│   └── hair_procedural_super_shine.fx / _realistic.fx
└── README.md
```

---

## Variants: Standard vs `_realistic`

Each preset is provided in two variants:
- **`[name].fx`**: Standard alpha blend for solid hair meshes.
- **`[name]_realistic.fx`**: Includes Dave Hoskins `HASHED_ALPHA_TEST_ENABLE 1` band-limited stochastic alpha cutout for transparent polygon hair cards.

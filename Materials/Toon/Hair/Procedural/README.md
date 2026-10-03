# Toon Procedural Hair Materials (Cel-Shaded)

Cel-shaded duplicates of the `Materials/Hair/Procedural/` suite for **Ray-MMD ReForge**.

Combines procedural hair synthesis (`PROCEDURAL_HAIR 1`) with cel-shading (`CUSTOM_ENABLE 8`) and tuned lavender hair shadows:
- `customA = 0.75` (shadow terminator threshold)
- `customB = float3(0.55, 0.50, 0.78)` (cool lavender hair shadow color)

Requires `TOON_ENABLE 1` (or 2) in `ray.conf`.

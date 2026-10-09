import struct
import os

def build_standalone_fog_controller(filepath):
    """
    Constructs a fully compliant PMX 2.0 dummy controller model from scratch.
    Contains standard 11-vertex dummy marker mesh, 1 bone (Root), 42 controller morphs,
    and 2 display frames (Root and Facial/Exp) for Ray-MMD.
    """
    enc = 'utf-16-le'

    def w_str(s):
        b = s.encode(enc)
        return struct.pack('<i', len(b)) + b

    def w_idx(val, sz=1):
        if sz == 1:
            return struct.pack('<b', val)
        elif sz == 2:
            return struct.pack('<h', val)
        elif sz == 4:
            return struct.pack('<i', val)

    out = bytearray()

    # 1. Header: Magic & Version
    out.extend(b'PMX ')
    out.extend(struct.pack('<f', 2.0))

    # 2. Globals configuration:
    # [0] Encode: 0 (UTF-16LE)
    # [1] Additional Vec4 UVs: 0
    # [2] Vertex Index Size: 1 (uint8)
    # [3] Texture Index Size: 1 (int8)
    # [4] Material Index Size: 1 (int8)
    # [5] Bone Index Size: 1 (int8)
    # [6] Morph Index Size: 1 (int8)
    # [7] Rigid Body Index Size: 1 (int8)
    out.append(8)
    out.extend(bytes([0, 0, 1, 1, 1, 1, 1, 1]))

    # 3. Model Info
    out.extend(w_str('FogController'))
    out.extend(w_str('FogController'))
    out.extend(w_str('Physical Exponential Height Fog & Volumetric Godrays Controller for Ray-MMD'))
    out.extend(w_str('Physical Exponential Height Fog & Volumetric Godrays Controller for Ray-MMD'))

    # 4. Standard 11 dummy marker vertices for controller viewport selection
    dummy_vertices = [
        ((-0.155, 0.155, 2.5125), (-0.577, 0.577, 0.577), (0.0, 0.0)),
        ((-0.155, 0.155, -2.5125), (-0.577, 0.577, -0.577), (0.0, 0.0)),
        ((-0.155, -0.155, -2.5125), (-0.577, -0.577, -0.577), (0.0, 0.0)),
        ((-0.155, -0.155, 2.5125), (-0.577, -0.577, 0.577), (0.0, 0.0)),
        ((0.155, 0.155, -2.5125), (0.577, 0.577, -0.577), (0.0, 0.0)),
        ((0.155, -0.155, -2.5125), (0.577, -0.577, -0.577), (0.0, 0.0)),
        ((0.155, 0.155, 2.5125), (0.577, 0.577, 0.577), (0.0, 0.0)),
        ((0.155, -0.155, 2.5125), (0.577, -0.577, 0.577), (0.0, 0.0)),
        ((-2.5125, 0.155, -0.155), (-0.577, 0.577, -0.577), (0.0, 0.0)),
        ((2.5125, 0.155, -0.155), (0.577, 0.577, -0.577), (0.0, 0.0)),
        ((0.0, -0.022, 0.022), (0.0, -0.707, 0.707), (0.0, 0.0)),
    ]

    out.extend(struct.pack('<i', len(dummy_vertices)))
    for pos, norm, uv in dummy_vertices:
        out.extend(struct.pack('<fff', *pos))
        out.extend(struct.pack('<fff', *norm))
        out.extend(struct.pack('<ff', *uv))
        out.append(0)           # Weight type: 0 (BDEF1)
        out.extend(w_idx(0, 1)) # Bone index 0
        out.extend(struct.pack('<f', 1.0)) # Edge scale

    # 5. Surfaces (42 indices = 14 triangles)
    dummy_surfaces = [
        0, 1, 2,  0, 2, 3,  1, 4, 5,  1, 5, 2,  4, 6, 7,  4, 7, 5,
        0, 3, 6,  3, 7, 6,  1, 6, 4,  0, 6, 1,  2, 5, 3,  3, 5, 7,
        8, 9, 10, 8, 10, 9
    ]
    out.extend(struct.pack('<i', len(dummy_surfaces)))
    for idx in dummy_surfaces:
        out.append(idx) # 1 byte per index

    # 6. Textures (0)
    out.extend(struct.pack('<i', 0))

    # 7. Materials (1 material referencing the 42 surface indices)
    out.extend(struct.pack('<i', 1))
    out.extend(w_str('材質1'))
    out.extend(w_str(''))
    out.extend(struct.pack('<ffff', 0.0, 0.0, 0.0, 0.0)) # Diffuse (RGBA)
    out.extend(struct.pack('<fff', 0.0, 0.0, 0.0))        # Specular (RGB)
    out.extend(struct.pack('<f', 0.0))                   # Specular power
    out.extend(struct.pack('<fff', 0.0, 0.0, 0.0))        # Ambient (RGB)
    out.append(0)                                        # Drawing flags
    out.extend(struct.pack('<ffff', 0.0, 0.0, 0.0, 1.0)) # Edge color (RGBA)
    out.extend(struct.pack('<f', 1.0))                   # Edge scale
    out.extend(w_idx(-1, 1))                             # Texture index (-1: None)
    out.extend(w_idx(-1, 1))                             # Sphere texture index (-1: None)
    out.append(2)                                        # Sphere mode
    out.append(0)                                        # Shared toon flag (0)
    out.extend(w_idx(-1, 1))                             # Toon texture index (-1: None)
    out.extend(w_str(''))                                # Memo
    out.extend(struct.pack('<i', len(dummy_surfaces)))   # Surface count: 42

    # 8. Bones (1 bone: 全ての親 / Root)
    out.extend(struct.pack('<i', 1))
    out.extend(w_str('全ての親'))
    out.extend(w_str(''))
    out.extend(struct.pack('<fff', 0.0, 0.0, 0.0)) # Pos (0, 0, 0)
    out.extend(w_idx(-1, 1))                      # Parent: None (-1)
    out.extend(struct.pack('<i', 0))              # Transform layer: 0
    out.extend(struct.pack('<H', 0x001F))         # Flags: connection target=bone index, rotate, move, display, operate
    out.extend(w_idx(-1, 1))                      # Target bone: None (-1)

    # 9. Morphs (42 dummy controller morphs)
    morphs = [
        # Eyebrow Panel (1) - Density & Opacity
        ('FogDensity+', 1),
        ('FogDensity-', 1),
        ('GroundDensity+', 1),
        ('GroundDensity-', 1),
        ('MaxOpacity+', 1),
        ('MaxOpacity-', 1),

        # Eye Panel (2) - Color & Sunlight
        ('FogR+', 2),
        ('FogR-', 2),
        ('FogG+', 2),
        ('FogG-', 2),
        ('FogB+', 2),
        ('FogB-', 2),
        ('SunR+', 2),
        ('SunR-', 2),
        ('SunG+', 2),
        ('SunG-', 2),
        ('SunB+', 2),
        ('SunB-', 2),
        ('SunIntensity+', 2),
        ('SunIntensity-', 2),
        ('MiePhase+', 2),
        ('MiePhase-', 2),

        # Lip / Other Panel (3) - Height, Falloff & Bounds
        ('FogHeight+', 3),
        ('FogHeight-', 3),
        ('HeightFalloff+', 3),
        ('HeightFalloff-', 3),
        ('GroundHeight+', 3),
        ('GroundHeight-', 3),
        ('GroundFalloff+', 3),
        ('GroundFalloff-', 3),
        ('StartDistance+', 3),
        ('StartDistance-', 3),
        ('CutoffDistance+', 3),
        ('CutoffDistance-', 3),

        # Other Panel (4) - Godrays & Volumetric Noise
        ('Godrays+', 4),
        ('Godrays-', 4),
        ('RayDensity+', 4),
        ('RayDensity-', 4),
        ('MistNoise+', 4),
        ('MistNoise-', 4),
        ('WindSpeed+', 4),
        ('WindSpeed-', 4),
    ]

    out.extend(struct.pack('<i', len(morphs)))
    for m_name, panel in morphs:
        out.extend(w_str(m_name))
        out.extend(w_str(m_name))
        out.append(panel)                # Panel (1..4)
        out.append(0)                    # Morph type: 0 (Group morph)
        out.extend(struct.pack('<i', 0)) # Offset count: 0

    # 10. Display Frames (2 frames: Root and 表情 / Exp)
    out.extend(struct.pack('<i', 2))

    # Frame 0: Root (contains bone 0)
    out.extend(w_str('Root'))
    out.extend(w_str('Root'))
    out.append(1)                    # Special flag: 1
    out.extend(struct.pack('<i', 1)) # Element count: 1
    out.append(0)                    # Element type: 0 (Bone)
    out.extend(w_idx(0, 1))          # Bone index: 0

    # Frame 1: 表情 (contains all 42 morphs)
    out.extend(w_str('表情'))
    out.extend(w_str('Exp'))
    out.append(1)                               # Special flag: 1
    out.extend(struct.pack('<i', len(morphs)))  # Element count: 42
    for i in range(len(morphs)):
        out.append(1)          # Element type: 1 (Morph)
        out.extend(w_idx(i, 1)) # Morph index: i

    # 11. Rigid Bodies (0) & Joints (0)
    out.extend(struct.pack('<i', 0))
    out.extend(struct.pack('<i', 0))

    with open(filepath, 'wb') as f:
        f.write(out)

    print(f"[SUCCESS] Generated standalone PMX: {filepath} ({len(out)} bytes)")

if __name__ == '__main__':
    dst = os.path.join(os.path.dirname(__file__), '..', 'FogController.pmx')
    build_standalone_fog_controller(dst)


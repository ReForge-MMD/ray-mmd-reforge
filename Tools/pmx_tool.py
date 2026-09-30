import struct
import sys
import os

class PMXParser:
    def __init__(self, filepath):
        self.filepath = filepath
        with open(filepath, 'rb') as f:
            self.data = f.read()
        self.pos = 0

    def read_bytes(self, n):
        res = self.data[self.pos:self.pos+n]
        self.pos += n
        return res

    def read_int(self):
        res = struct.unpack('<i', self.data[self.pos:self.pos+4])[0]
        self.pos += 4
        return res

    def read_float(self):
        res = struct.unpack('<f', self.data[self.pos:self.pos+4])[0]
        self.pos += 4
        return res

    def read_byte(self):
        res = self.data[self.pos]
        self.pos += 1
        return res

    def read_string(self, encoding):
        length = self.read_int()
        if length == 0:
            return ""
        s_bytes = self.read_bytes(length)
        return s_bytes.decode(encoding, errors='ignore')

    def read_index(self, size):
        if size == 1:
            val = struct.unpack('<b', self.read_bytes(1))[0]
        elif size == 2:
            val = struct.unpack('<h', self.read_bytes(2))[0]
        elif size == 4:
            val = struct.unpack('<i', self.read_bytes(4))[0]
        return val

    def read_uindex(self, size):
        if size == 1:
            val = struct.unpack('<B', self.read_bytes(1))[0]
        elif size == 2:
            val = struct.unpack('<H', self.read_bytes(2))[0]
        elif size == 4:
            val = struct.unpack('<I', self.read_bytes(4))[0]
        return val

def write_string(text, encoding):
    b = text.encode(encoding)
    return struct.pack('<i', len(b)) + b

def write_index(val, size):
    if size == 1:
        return struct.pack('<b', val)
    elif size == 2:
        return struct.pack('<h', val)
    elif size == 4:
        return struct.pack('<i', val)

def write_uindex(val, size):
    if size == 1:
        return struct.pack('<B', val)
    elif size == 2:
        return struct.pack('<H', val)
    elif size == 4:
        return struct.pack('<I', val)

def parse_and_add_morphs(filepath, new_morph_names, output_filepath=None):
    if output_filepath is None:
        output_filepath = filepath

    p = PMXParser(filepath)
    magic = p.read_bytes(4)
    if magic != b'PMX ':
        raise ValueError("Not a valid PMX file")

    version = p.read_float()
    g_cnt = p.read_byte()
    globals_data = p.read_bytes(g_cnt)
    encoding = 'utf-16-le' if globals_data[0] == 0 else 'utf-8'

    add_uv = globals_data[1]
    v_idx_sz = globals_data[2]
    tex_idx_sz = globals_data[3]
    mat_idx_sz = globals_data[4]
    bone_idx_sz = globals_data[5]
    morph_idx_sz = globals_data[6]
    rb_idx_sz = globals_data[7]

    # Save header part
    header_part = p.data[:p.pos]

    # Model Info
    name_jp = p.read_string(encoding)
    name_en = p.read_string(encoding)
    comm_jp = p.read_string(encoding)
    comm_en = p.read_string(encoding)

    # Vertices
    v_cnt = p.read_int()
    for _ in range(v_cnt):
        p.read_bytes(12 + 12 + 8) # pos, normal, uv
        for _ in range(add_uv):
            p.read_bytes(16)
        weight_type = p.read_byte()
        if weight_type == 0: # BDEF1
            p.read_index(bone_idx_sz)
        elif weight_type == 1: # BDEF2
            p.read_index(bone_idx_sz)
            p.read_index(bone_idx_sz)
            p.read_float()
        elif weight_type == 2: # BDEF4
            p.read_index(bone_idx_sz)
            p.read_index(bone_idx_sz)
            p.read_index(bone_idx_sz)
            p.read_index(bone_idx_sz)
            p.read_float(); p.read_float(); p.read_float(); p.read_float()
        elif weight_type == 3: # SDEF
            p.read_index(bone_idx_sz)
            p.read_index(bone_idx_sz)
            p.read_float()
            p.read_bytes(36)
        elif weight_type == 4: # QDEF
            p.read_index(bone_idx_sz)
            p.read_index(bone_idx_sz)
            p.read_index(bone_idx_sz)
            p.read_index(bone_idx_sz)
            p.read_float(); p.read_float(); p.read_float(); p.read_float()
        p.read_float() # edge scale

    # Surfaces (Indices)
    s_cnt = p.read_int()
    p.read_bytes(s_cnt * v_idx_sz)

    # Textures
    t_cnt = p.read_int()
    for _ in range(t_cnt):
        p.read_string(encoding)

    # Materials
    m_cnt = p.read_int()
    for _ in range(m_cnt):
        p.read_string(encoding) # name jp
        p.read_string(encoding) # name en
        p.read_bytes(4*4 + 4*3 + 4 + 4*3 + 1 + 4*4 + 4 + 1) # diffuse, specular, spec power, ambient, flag, edge col, edge sz, tex idx
        p.read_index(tex_idx_sz) # sphere tex
        p.read_byte() # sphere mode
        toon_flag = p.read_byte()
        if toon_flag == 0:
            p.read_index(tex_idx_sz)
        else:
            p.read_byte()
        p.read_string(encoding) # memo
        p.read_int() # surface count

    # Bones
    b_cnt = p.read_int()
    for _ in range(b_cnt):
        p.read_string(encoding)
        p.read_string(encoding)
        p.read_bytes(12) # pos
        p.read_index(bone_idx_sz) # parent
        p.read_int() # layer
        flag = struct.unpack('<H', p.read_bytes(2))[0]
        if flag & 0x0001:
            p.read_index(bone_idx_sz)
        else:
            p.read_bytes(12)
        if flag & (0x0100 | 0x0200):
            p.read_index(bone_idx_sz)
            p.read_float()
        if flag & 0x0400:
            p.read_bytes(12)
        if flag & 0x0800:
            p.read_bytes(12); p.read_bytes(12)
        if flag & 0x2000:
            p.read_int()
        if flag & 0x0020:
            ik_target = p.read_index(bone_idx_sz)
            p.read_int(); p.read_float()
            link_cnt = p.read_int()
            for _ in range(link_cnt):
                p.read_index(bone_idx_sz)
                has_limit = p.read_byte()
                if has_limit:
                    p.read_bytes(12 + 12)

    # Morphs
    morph_start_pos = p.pos
    morph_cnt = p.read_int()
    existing_morphs = []
    
    morph_data_bytes = bytearray()
    
    for m_idx in range(morph_cnt):
        m_start = p.pos
        name_j = p.read_string(encoding)
        name_e = p.read_string(encoding)
        after_names_pos = p.pos
        panel = p.read_byte()
        m_type = p.read_byte()
        o_cnt = p.read_int()
        
        # Read offset items
        for _ in range(o_cnt):
            if m_type == 0: # Group
                p.read_index(morph_idx_sz)
                p.read_float()
            elif m_type == 1: # Vertex
                p.read_index(v_idx_sz)
                p.read_bytes(12)
            elif m_type == 2: # Bone
                p.read_index(bone_idx_sz)
                p.read_bytes(12 + 16)
            elif m_type in (3, 4, 5, 6, 7): # UV
                p.read_index(v_idx_sz)
                p.read_bytes(16)
            elif m_type == 8: # Material
                p.read_index(mat_idx_sz)
                p.read_bytes(1 + 4*4 + 4*3 + 4 + 4*3 + 4*4 + 4 + 4*4)
            elif m_type == 9: # Flip
                p.read_index(morph_idx_sz)
                p.read_float()
            elif m_type == 10: # Impulse
                p.read_index(rb_idx_sz)
                p.read_bytes(1 + 12 + 12)

        m_end = p.pos
        
        if 'Blade' in name_j or 'Blade' in name_e:
            m_bin = bytearray()
            m_bin.extend(write_string(name_j, encoding))
            m_bin.extend(write_string(name_e, encoding))
            m_bin.append(3) # Panel: 3 = Mouth/Lip (Camera & DOF)
            m_bin.extend(p.data[after_names_pos + 1:m_end])
            morph_data_bytes.extend(m_bin)
            existing_morphs.append(name_j)
            print(f"[*] Updated Morph Panel: {name_j} -> Panel 3 (Mouth/Lip)")
        elif 'VXGI' in name_j or 'VXGI' in name_e:
            new_name_j = name_j.replace('VXGI', 'SSGI')
            new_name_e = name_e.replace('VXGI', 'SSGI')
            m_bin = bytearray()
            m_bin.extend(write_string(new_name_j, encoding))
            m_bin.extend(write_string(new_name_e, encoding))
            m_bin.extend(p.data[after_names_pos:m_end])
            morph_data_bytes.extend(m_bin)
            existing_morphs.append(new_name_j)
            print(f"[*] Renamed Morph: {name_j} -> {new_name_j}")
        else:
            morph_data_bytes.extend(p.data[m_start:m_end])
            existing_morphs.append(name_j)

    # Filter out already existing morphs
    added_morph_indices = []
    current_morph_count = morph_cnt
    
    for new_name in new_morph_names:
        if new_name not in existing_morphs:
            # Assign proper panel category based on morph name
            if any(k in new_name for k in ('Blade', 'Fstop', 'Focal', 'Measure', 'Alpha')):
                panel_id = 3 # Mouth / Lip (Camera / Alpha G-buffers)
            elif any(k in new_name for k in ('SSGI', 'GI')):
                panel_id = 4 # Other (GI controls)
            elif any(k in new_name for k in ('Shadow', 'PSSM', 'Cascade', 'SSGS', 'SSAO', 'SSDO', 'SSR', 'Outline', 'Contact')):
                panel_id = 1 # Brows (Shadows & Post-Effects)
            else:
                panel_id = 2 # Eyes (Opaque G-buffers)

            m_bin = bytearray()
            m_bin.extend(write_string(new_name, encoding))
            m_bin.extend(write_string(new_name, encoding))
            m_bin.append(panel_id)
            m_bin.append(0) # Type: 0 = Group
            m_bin.extend(struct.pack('<i', 0)) # Offset count = 0
            
            morph_data_bytes.extend(m_bin)
            added_morph_indices.append(current_morph_count)
            current_morph_count += 1
            print(f"[+] Morph added: {new_name} (index {current_morph_count-1}, panel {panel_id})")
        else:
            print(f"[=] Morph already exists: {new_name}")

    # Rest of PMX file (Display Frames, Rigid Bodies, Joints, etc.)
    rest_data = p.data[p.pos:]
    
    # Write updated PMX file
    out = bytearray()
    out.extend(p.data[:morph_start_pos])
    out.extend(struct.pack('<i', current_morph_count))
    out.extend(morph_data_bytes)

    # Now handle Display Frames (if we added morphs, append them to Panel 1 / morph display group)
    p_rest = PMXParser(filepath)
    p_rest.pos = p.pos
    df_cnt = p_rest.read_int()
    
    df_start = p.pos
    df_end = p_rest.pos
    
    # Write updated display frames
    df_bin = bytearray()
    df_bin.extend(struct.pack('<i', df_cnt))
    
    for df_i in range(df_cnt):
        df_j = p_rest.read_string(encoding)
        df_e = p_rest.read_string(encoding)
        special = p_rest.read_byte()
        e_cnt = p_rest.read_int()
        
        elem_bytes = bytearray()
        for _ in range(e_cnt):
            elem_type = p_rest.read_byte()
            elem_idx = p_rest.read_index(morph_idx_sz if elem_type == 1 else bone_idx_sz)
            elem_bytes.append(elem_type)
            elem_bytes.extend(write_index(elem_idx, morph_idx_sz if elem_type == 1 else bone_idx_sz))
            
        # If this is the Facial / Morph display frame (usually df_i == 1 or df_j == '表情'), add new morphs
        if added_morph_indices and (df_i == 1 or '表情' in df_j or 'Facial' in df_e):
            for add_idx in added_morph_indices:
                elem_bytes.append(1) # Type 1 = Morph
                elem_bytes.extend(write_index(add_idx, morph_idx_sz))
            e_cnt += len(added_morph_indices)
            print(f"[+] Added {len(added_morph_indices)} morphs to Display Frame: {df_j}")

        df_bin.extend(write_string(df_j, encoding))
        df_bin.extend(write_string(df_e, encoding))
        df_bin.append(special)
        df_bin.extend(struct.pack('<i', e_cnt))
        df_bin.extend(elem_bytes)

    out.extend(df_bin)
    out.extend(p.data[p_rest.pos:])

    with open(output_filepath, 'wb') as f_out:
        f_out.write(out)
    print(f"[SUCCESS] Updated PMX saved to {output_filepath}")

if __name__ == '__main__':
    target = r'LightingController.pmx'
    if len(sys.argv) > 1:
        target = sys.argv[1]
    
    new_morphs = ['SSGI+', 'SSGI-']
    parse_and_add_morphs(target, new_morphs)

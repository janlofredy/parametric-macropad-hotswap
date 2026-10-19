import math
import struct
import os

def write_binary_stl(filename, facets):
    with open(filename, 'wb') as f:
        header = b'Pure 3D-Printable Split Snap Rivet / Locking Pin'.ljust(80, b'\0')
        f.write(header)
        f.write(struct.pack('<I', len(facets)))
        for norm, v1, v2, v3 in facets:
            f.write(struct.pack('<3f', *norm))
            f.write(struct.pack('<3f', *v1))
            f.write(struct.pack('<3f', *v2))
            f.write(struct.pack('<3f', *v3))
            f.write(b'\0\0')

def calc_normal(v1, v2, v3):
    ax, ay, az = v2[0] - v1[0], v2[1] - v1[1], v2[2] - v1[2]
    bx, by, bz = v3[0] - v1[0], v3[1] - v1[1], v3[2] - v1[2]
    nx = ay * bz - az * by
    ny = az * bx - ax * bz
    nz = ax * by - ay * bx
    l = math.sqrt(nx*nx + ny*ny + nz*nz)
    if l < 1e-9:
        return (0.0, 0.0, 1.0)
    return (nx/l, ny/l, nz/l)

def add_cylinder(r1, r2, z1, z2, facets, n_segments=32, center=(0, 0)):
    cx, cy = center
    angles = [2.0 * math.pi * i / n_segments for i in range(n_segments)]
    c1 = [(cx + r1 * math.cos(a), cy + r1 * math.sin(a), z1) for a in angles]
    c2 = [(cx + r2 * math.cos(a), cy + r2 * math.sin(a), z2) for a in angles]
    
    for i in range(n_segments):
        nxt = (i + 1) % n_segments
        # Quad between circle 1 and circle 2
        f1 = (calc_normal(c1[i], c1[nxt], c2[nxt]), c1[i], c1[nxt], c2[nxt])
        f2 = (calc_normal(c1[i], c2[nxt], c2[i]), c1[i], c2[nxt], c2[i])
        facets.extend([f1, f2])

def add_cap(r, z, normal_up, facets, n_segments=32, center=(0, 0)):
    cx, cy = center
    center_pt = (cx, cy, z)
    angles = [2.0 * math.pi * i / n_segments for i in range(n_segments)]
    pts = [(cx + r * math.cos(a), cy + r * math.sin(a), z) for a in angles]
    norm = (0.0, 0.0, 1.0 if normal_up else -1.0)
    for i in range(n_segments):
        nxt = (i + 1) % n_segments
        if normal_up:
            facets.append((norm, center_pt, pts[i], pts[nxt]))
        else:
            facets.append((norm, center_pt, pts[nxt], pts[i]))

def generate_snap_pin(cx=0, cy=0):
    facets = []
    # Head: d=5.2, h=1.4
    r_head = 2.6
    r_pin = 1.35 # fits in 2.8mm hole with 0.1mm clearance
    grip_len = 9.5
    barb_len = 2.2
    
    # Head cap
    add_cylinder(r_head, r_head, 0, 1.0, facets, n_segments=32, center=(cx, cy))
    add_cylinder(r_head, r_head - 0.6, 1.0, 1.4, facets, n_segments=32, center=(cx, cy))
    add_cap(r_head - 0.6, 1.4, True, facets, n_segments=32, center=(cx, cy))
    
    # Underside of head
    # ring from r_pin to r_head at z=0 (facing down)
    angles = [2.0 * math.pi * i / 32 for i in range(32)]
    for i in range(32):
        nxt = (i + 1) % 32
        p1 = (cx + r_pin * math.cos(angles[i]), cy + r_pin * math.sin(angles[i]), 0)
        p2 = (cx + r_head * math.cos(angles[i]), cy + r_head * math.sin(angles[i]), 0)
        p3 = (cx + r_head * math.cos(angles[nxt]), cy + r_head * math.sin(angles[nxt]), 0)
        p4 = (cx + r_pin * math.cos(angles[nxt]), cy + r_pin * math.sin(angles[nxt]), 0)
        norm = (0.0, 0.0, -1.0)
        facets.append((norm, p1, p3, p2))
        facets.append((norm, p1, p4, p3))
        
    # Main shank
    add_cylinder(r_pin, r_pin, -grip_len, 0, facets, n_segments=32, center=(cx, cy))
    
    # Barbed flange (r increases to 1.65, then tapers to 1.0 at tip)
    r_barb = 1.65
    r_tip = 0.9
    z_barb_shelf = -grip_len
    z_barb_peak = -grip_len - 0.8
    z_tip = -grip_len - barb_len
    
    # Shelf expansion (facing up)
    for i in range(32):
        nxt = (i + 1) % 32
        p1 = (cx + r_pin * math.cos(angles[i]), cy + r_pin * math.sin(angles[i]), z_barb_shelf)
        p2 = (cx + r_barb * math.cos(angles[i]), cy + r_barb * math.sin(angles[i]), z_barb_shelf)
        p3 = (cx + r_barb * math.cos(angles[nxt]), cy + r_barb * math.sin(angles[nxt]), z_barb_shelf)
        p4 = (cx + r_pin * math.cos(angles[nxt]), cy + r_pin * math.sin(angles[nxt]), z_barb_shelf)
        norm = (0.0, 0.0, 1.0)
        facets.append((norm, p1, p2, p3))
        facets.append((norm, p1, p3, p4))
        
    # Barb body
    add_cylinder(r_barb, r_barb, z_barb_peak, z_barb_shelf, facets, n_segments=32, center=(cx, cy))
    # Barb lead-in taper
    add_cylinder(r_tip, r_barb, z_tip, z_barb_peak, facets, n_segments=32, center=(cx, cy))
    add_cap(r_tip, z_tip, False, facets, n_segments=32, center=(cx, cy))
    
    return facets

def main():
    os.makedirs('stl', exist_ok=True)
    # Generate batch of 4 pins arranged in a 2x2 grid
    all_facets = []
    positions = [(-5.0, -5.0), (5.0, -5.0), (-5.0, 5.0), (5.0, 5.0)]
    for px, py in positions:
        all_facets.extend(generate_snap_pin(px, py))
        
    output_path = 'stl/printable_locking_pins_set_of_4.stl'
    write_binary_stl(output_path, all_facets)
    print(f"Generated {output_path} with {len(all_facets)} triangles!")

if __name__ == '__main__':
    main()

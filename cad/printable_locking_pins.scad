// ==============================================================================
// 100% 3D-PRINTABLE LOCKING PINS / SNAP RIVETS (ZERO HARDWARE FASTENERS)
// ==============================================================================
// Purpose:
//  - Clamps the 3 layers (Top Plate + Midplate + Bottom Case) firmly together
//  - Eliminates M2 screws, nuts, and brass heat-set inserts entirely
//  - 100% pure 3D printed assembly!
// ==============================================================================

/* [Pin Parameters] */
// Style of fastener:
// "snap_rivet"   : Split-shank bifurcated push pin with barbed locking heads
// "taper_dowel"  : Precision tapered friction-lock alignment dowel
pin_style = "snap_rivet"; // [snap_rivet, taper_dowel]

// Total grip stack length through all 3 plates (Top Plate 2.0mm + Mid 5.2mm + Bottom 2.0mm = 9.2mm)
grip_length = 9.5;

// Hole clearance diameter (matches 2.8mm corner holes in plates)
hole_diameter = 2.7;

// Low-profile top cap head diameter
head_diameter = 5.2;
head_thickness = 1.4;

// Print batch quantity on build plate
quantity = 4; // [1:8]

$fn = 36;

// ------------------------------------------------------------------------------
// MAIN RENDER (Arranged in a grid for 3D printing)
// ------------------------------------------------------------------------------
pin_spacing = head_diameter + 4.0;
cols = min(quantity, 4);

for (i = [0 : quantity - 1]) {
    col = i % cols;
    row = floor(i / cols);
    translate([col * pin_spacing, row * pin_spacing, 0]) {
        if (pin_style == "snap_rivet") {
            printable_snap_rivet(
                grip_len = grip_length,
                pin_d = hole_diameter,
                head_d = head_diameter,
                head_h = head_thickness
            );
        } else {
            printable_taper_dowel(
                grip_len = grip_length,
                pin_d = hole_diameter,
                head_d = head_diameter,
                head_h = head_thickness
            );
        }
    }
}

// ==============================================================================
// MODULE: BIFURCATED SNAP RIVET
// ==============================================================================
// Pushes through the top plate, down through midplate and bottom tray.
// The split flex prongs compress inward during insertion, then snap open
// with barbed lips under the bottom plate to permanently or semi-permanently
// lock the entire macropad sandwich together.
module printable_snap_rivet(
    grip_len = 9.5,
    pin_d = 2.7,
    head_d = 5.2,
    head_h = 1.4
) {
    barb_len = 2.2;
    total_shank_len = grip_len + barb_len;
    slot_w = 0.8;
    slot_len = grip_len * 0.75 + barb_len;

    difference() {
        union() {
            // 1. Sleek Domed Low-Profile Head
            cylinder(d=head_d, h=head_h - 0.4);
            translate([0, 0, head_h - 0.4])
                cylinder(d1=head_d, d2=head_d - 1.2, h=0.4);

            // 2. Main Cylindrical Shank
            translate([0, 0, -grip_len])
                cylinder(d=pin_d, h=grip_len);

            // 3. Barbed Expanding Tip
            translate([0, 0, -total_shank_len]) {
                // Tapered lead-in cone for easy insertion
                cylinder(d1=pin_d - 0.8, d2=pin_d + 0.6, h=barb_len * 0.6);
                // Retaining locking step shoulder
                translate([0, 0, barb_len * 0.6])
                    cylinder(d1=pin_d + 0.6, d2=pin_d, h=barb_len * 0.4);
            }
        }

        // 4. Flexing Expansion Slot (bifurcates the shank into 2 spring prongs)
        translate([0, 0, -total_shank_len - 0.1])
            cube([slot_w, pin_d + 2.0, slot_len], center=true);
    }
}

// ==============================================================================
// MODULE: TAPERED FRICTION DOWEL
// ==============================================================================
module printable_taper_dowel(
    grip_len = 9.5,
    pin_d = 2.7,
    head_d = 5.2,
    head_h = 1.4
) {
    // Low-profile top cap
    cylinder(d=head_d, h=head_h);
    // Slight taper (0.15mm) along the length creates high-friction wedge lock
    translate([0, 0, -grip_len])
        cylinder(d1=pin_d - 0.2, d2=pin_d + 0.05, h=grip_len);
}

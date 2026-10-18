// ==============================================================================
// MODULAR EC11 ROTARY ENCODER HOTSWAP SOCKET (WITH PUSH SWITCH)
// ==============================================================================
// Designed for Parametric Macropads & Keyboards
// Compatible with standard Alps Alpine EC11 and Bourns PEC11 clickable encoders
// ==============================================================================

// Standalone test render if root file
if ($preview && is_undef(is_grid_plate_parent)) {
    ec11_hotswap_socket(include_mount_tabs = true, include_diode = false);
}

// ------------------------------------------------------------------------------
// POSITIVE STANDALONE MODULE
// ------------------------------------------------------------------------------
module ec11_hotswap_socket(
    body_w = 15.4,
    body_l = 15.4,
    body_h = 5.2,
    include_mount_tabs = true,
    include_diode = false,
    clearance = 0.20
) {
    difference() {
        // Solid outer body with rounded corners
        union() {
            ec11_rounded_box(body_w, body_l, body_h, r=1.0);
            if (include_mount_tabs) {
                ec11_mounting_tabs(body_w);
            }
        }

        // Apply clean negative cutouts with proper wall clearance & zero Z-fighting
        ec11_socket_negative(
            clearance = clearance,
            body_h = body_h,
            include_diode = include_diode,
            body_w = body_w,
            body_l = body_l
        );
    }
}

// ------------------------------------------------------------------------------
// NEGATIVE CUTOUT MODULE (For Standalone Socket & Monolithic Gridplates)
// ------------------------------------------------------------------------------
module ec11_socket_negative(
    clearance = 0.20,
    body_h = 5.2,
    include_diode = false,
    body_w = 15.4,
    body_l = 15.4
) {
    // Standard EC11 body & pin specs (Alps / Bourns PEC11)
    ec11_w = 12.0 + (clearance * 2);
    ec11_l = 12.0 + (clearance * 2);
    pocket_depth = 2.2;

    // Pin row positions relative to center shaft (0, 0)
    // Standard EC11: 3 encoder pins at Y = -5.5mm, 2 switch pins at Y = +5.0mm
    enc_pin_y = -5.5;
    sw_pin_y  =  5.0;
    pin_pitch =  2.50; // Pin A (-2.5), C (0.0), B (+2.5)

    // Receptacle hole diameter (fits Mill-Max 0305 / 2.54mm Dupont terminal sleeves)
    receptacle_d = 1.60 + (clearance * 2);

    // 1. EC11 Main Body Pocket (Top Face) - with +0.1mm epsilon to prevent Z-fighting
    translate([0, 0, body_h - pocket_depth])
        translate([0, 0, 0.05])
            ec11_rounded_box(ec11_w, ec11_l, pocket_depth + 0.1, r=0.8);

    // 2. Anti-Torque Chassis Bracket Slots at X = +/- 6.0mm
    // Sized for metal side tabs (~1.8mm x 0.5mm), extends into pocket floor
    translate([-6.0, 0, body_h - pocket_depth - 1.5])
        cube([2.2, 1.2, 3.5], center=true);
    translate([ 6.0, 0, body_h - pocket_depth - 1.5])
        cube([2.2, 1.2, 3.5], center=true);

    // 3. Encoder 3 Pin Receptacles (Pin A, Common/GND, Pin B at Y = -5.5mm)
    for (i = [-1, 0, 1]) {
        px = i * pin_pitch;

        // Conical lead-in funnel on pocket floor (d2 = 2.4mm max to keep solid wall)
        translate([px, enc_pin_y, body_h - pocket_depth - 1.0])
            cylinder(d1=receptacle_d, d2=2.4, h=1.01, $fn=24);

        // Through-hole for terminal receptacle
        translate([px, enc_pin_y, -0.5])
            cylinder(d=receptacle_d, h=body_h + 1, $fn=24);

        // Underside solder cup / wire routing pocket (stays enclosed inside bottom face)
        translate([px, enc_pin_y, 0.5])
            cube([receptacle_d + 0.6, 2.0, 1.2], center=true);
    }

    // 4. Push Switch 2 Pin Receptacles (SW1, SW2 at Y = +5.0mm, X = +/- 2.5mm)
    for (sx = [-2.5, 2.5]) {
        // Conical lead-in funnel
        translate([sx, sw_pin_y, body_h - pocket_depth - 1.0])
            cylinder(d1=receptacle_d, d2=2.4, h=1.01, $fn=24);

        // Through-hole
        translate([sx, sw_pin_y, -0.5])
            cylinder(d=receptacle_d, h=body_h + 1, $fn=24);

        // Underside solder cup
        translate([sx, sw_pin_y, 0.5])
            cube([receptacle_d + 0.6, 2.0, 1.2], center=true);
    }

    // 5. Optional 1N4148 Diode Bay for Push Switch (Skipped if include_diode is false)
    if (include_diode) {
        translate([0.0, 3.0, 0.8]) {
            cube([4.8, 2.0, 1.8], center=true);
            // Trace slit linking SW2 to diode anode
            translate([1.2, 1.2, 0]) cube([1.0, 2.4, 1.8], center=true);
        }
    }

    // 6. Underside Wire Channels (Recessed trenches with clean enclosed margins)
    // Switch connection channel (linking SW1 and SW2 across bottom)
    translate([0, sw_pin_y, 0.6])
        cube([7.0, 1.3, 1.2], center=true);

    // Encoder connection channel (linking A, C, B across bottom)
    translate([0, enc_pin_y, 0.6])
        cube([7.0, 1.3, 1.2], center=true);

    // Direct wire exit channels towards bottom edge (depth 1.0mm, width 1.3mm)
    for (i = [-1, 0, 1]) {
        px = i * pin_pitch;
        translate([px, enc_pin_y - 1.1, 0.5])
            cube([1.3, 2.2, 1.0], center=true);
    }
}

// ------------------------------------------------------------------------------
// HELPER GEOMETRY MODULES
// ------------------------------------------------------------------------------
module ec11_rounded_box(w, l, h, r=1.0) {
    hull() {
        translate([-w/2 + r, -l/2 + r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([ w/2 - r, -l/2 + r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([ w/2 - r,  l/2 - r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([-w/2 + r,  l/2 - r, 0]) cylinder(r=r, h=h, $fn=24);
    }
}

module ec11_mounting_tabs(body_w) {
    difference() {
        union() {
            translate([-body_w/2 - 2.5, 0, 0]) ec11_rounded_box(5.0, 7.0, 2.4, r=1.0);
            translate([ body_w/2 + 2.5, 0, 0]) ec11_rounded_box(5.0, 7.0, 2.4, r=1.0);
        }
        translate([-body_w/2 - 2.5, 0, -1]) cylinder(d=2.2, h=5, $fn=24);
        translate([ body_w/2 + 2.5, 0, -1]) cylinder(d=2.2, h=5, $fn=24);
    }
}

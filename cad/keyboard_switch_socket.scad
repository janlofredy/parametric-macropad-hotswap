// ==============================================================================
// MODULAR KEYBOARD SWITCH HOTSWAP SOCKET (CHERRY MX / KAILH CPG151101S01)
// ==============================================================================
// Can be used standalone OR included into `macropad_grid_plate.scad`
// ==============================================================================

// Standalone test render if root file
if ($preview && is_undef(is_grid_plate_parent)) {
    mx_hotswap_socket(include_mount_tabs = true, include_diode = false);
}

// ------------------------------------------------------------------------------
// POSITIVE STANDALONE MODULE
// ------------------------------------------------------------------------------
module mx_hotswap_socket(
    body_w = 15.4,
    body_l = 15.4,
    body_h = 5.2,
    include_mount_tabs = true,
    include_diode = false,
    clearance = 0.20
) {
    difference() {
        union() {
            mx_rounded_box(body_w, body_l, body_h, r=1.0);
            if (include_mount_tabs) {
                mx_mounting_tabs(body_w);
            }
        }
        // Apply standard negative cutouts
        mx_socket_negative(clearance = clearance, body_h = body_h, include_diode = include_diode);
    }
}

// ------------------------------------------------------------------------------
// NEGATIVE CUTOUT MODULE (For Monolithic Gridplates)
// ------------------------------------------------------------------------------
module mx_socket_negative(clearance = 0.20, body_h = 5.2, include_diode = false) {
    stem_d = 4.0 + (clearance * 2);
    stab_d = 1.7 + (clearance * 2);

    // 1. Top Switch Housing Seating Recess (14.1 x 14.1mm, 1.0mm deep) with +0.1 epsilon
    translate([0, 0, body_h - 0.5])
        translate([0, 0, 0.05])
            cube([14.1, 14.1, 1.1], center=true);

    // 2. Center Stem Hole (Through)
    translate([0, 0, -1])
        cylinder(d=stem_d, h=body_h + 2, $fn=32);

    // 3. 5-Pin Stabilizer Leg Holes (X = +/- 5.08mm)
    translate([-5.08, 0, -1]) cylinder(d=stab_d, h=body_h + 2, $fn=24);
    translate([ 5.08, 0, -1]) cylinder(d=stab_d, h=body_h + 2, $fn=24);

    // 4. Pin 1 Funnel & Slot (-3.81, 2.54)
    translate([-3.81, 2.54, body_h - 1.2]) cylinder(d1=1.4, d2=2.6, h=1.3, $fn=24);
    translate([-3.81, 2.54, -0.5]) cylinder(d=1.4, h=body_h + 1, $fn=24);

    // 5. Pin 2 Funnel & Slot (+2.54, 5.08)
    translate([2.54, 5.08, body_h - 1.2]) cylinder(d1=1.4, d2=2.6, h=1.3, $fn=24);
    translate([2.54, 5.08, -0.5]) cylinder(d=1.4, h=body_h + 1, $fn=24);

    // 6. Kailh Socket Body Pocket (CPG151101S01, underside)
    translate([-0.5, 3.8, 1.4])
        mx_rounded_box(13.2, 5.8, 3.0, r=0.8);
    // Solder lug pockets
    translate([-6.5, 2.54, 1.3]) cube([3.2, 2.8, 2.8], center=true);
    translate([ 5.8, 5.08, 1.3]) cube([3.2, 2.8, 2.8], center=true);

    // 7. Optional 1N4148 Diode Pocket
    if (include_diode) {
        translate([0.5, -2.5, 1.0]) {
            cube([5.0, 2.2, 2.2], center=true);
            // Wire bridge to Pin 2
            translate([1.8, 2.5, 0]) cube([1.0, 5.0, 2.2], center=true);
        }
    }

    // 8. Direct Contact Wire Channels (Underside - Short-Proof)
    // Terminal 1 Channel: Horizontal Ground bus channel running directly through Terminal 1 solder wing at (X = -6.5, Y = 2.54)
    translate([0, 2.54, 0.7]) cube([body_w + 5, 1.6, 1.4], center=true);

    // Terminal 2 Channel: Signal wire channel running directly from Terminal 2 solder wing at (X = 5.8, Y = 5.08) exiting towards +Y
    translate([5.8, 6.2, 0.7]) cube([1.6, 4.5, 1.4], center=true);
}

module mx_rounded_box(w, l, h, r=1.0) {
    hull() {
        translate([-w/2 + r, -l/2 + r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([ w/2 - r, -l/2 + r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([ w/2 - r,  l/2 - r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([-w/2 + r,  l/2 - r, 0]) cylinder(r=r, h=h, $fn=24);
    }
}

module mx_mounting_tabs(body_w) {
    difference() {
        union() {
            translate([-body_w/2 - 2.5, 0, 0]) mx_rounded_box(5.0, 7.0, 2.4, r=1.0);
            translate([ body_w/2 + 2.5, 0, 0]) mx_rounded_box(5.0, 7.0, 2.4, r=1.0);
        }
        translate([-body_w/2 - 2.5, 0, -1]) cylinder(d=2.2, h=5, $fn=24);
        translate([ body_w/2 + 2.5, 0, -1]) cylinder(d=2.2, h=5, $fn=24);
    }
}

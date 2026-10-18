// ==============================================================================
// 100% SOLDERLESS WIRE-PINCH HOTSWAP SOCKET FOR MECHANICAL SWITCHES (CHERRY MX)
// ==============================================================================
// Zero Soldering! Zero Bought Kailh Sockets! Zero Diodes!
// How it works:
//  - Uses bare 22-24 AWG solid copper wire (or stripped Cat5/Cat6 ethernet wire).
//  - You thread the wire through the built-in 3D-printed captive guide tunnels.
//  - When you press an MX switch into the socket from the top, the switch's stiff
//    brass pins wedge against the bare copper wire on internal 15-degree spring ramps,
//    pinching the wire firmly against the plastic wall to create an electrical contact!
// ==============================================================================

// Standalone test render if root file
if ($preview && is_undef(is_grid_plate_parent)) {
    solderless_switch_socket(include_mount_tabs = true);
}

// ------------------------------------------------------------------------------
// POSITIVE STANDALONE MODULE
// ------------------------------------------------------------------------------
module solderless_switch_socket(
    body_w = 15.4,
    body_l = 15.4,
    body_h = 5.2,
    include_mount_tabs = true,
    clearance = 0.20
) {
    difference() {
        union() {
            sw_rounded_box(body_w, body_l, body_h, r=1.0);
            if (include_mount_tabs) {
                sw_mounting_tabs(body_w);
            }
        }
        // Apply 100% solderless wire-pinch negative cavities
        solderless_switch_negative(clearance = clearance, body_h = body_h, body_w = body_w, body_l = body_l);
    }
}

// ------------------------------------------------------------------------------
// NEGATIVE CAVITY MODULE (For Standalone Socket & Monolithic Gridplates)
// ------------------------------------------------------------------------------
module solderless_switch_negative(
    clearance = 0.20,
    body_h = 5.2,
    body_w = 15.4,
    body_l = 15.4
) {
    stem_d = 4.0 + (clearance * 2);
    stab_d = 1.7 + (clearance * 2);

    // 1. Top Switch Housing Seating Recess (14.1 x 14.1mm, 1.0mm deep)
    translate([0, 0, body_h - 0.5])
        translate([0, 0, 0.05])
            cube([14.1, 14.1, 1.1], center=true);

    // 2. Center Stem Bore (Through-hole)
    translate([0, 0, -1])
        cylinder(d=stem_d, h=body_h + 2, $fn=32);

    // 3. 5-Pin Stabilizer Leg Holes (X = +/- 5.08mm)
    translate([-5.08, 0, -1]) cylinder(d=stab_d, h=body_h + 2, $fn=24);
    translate([ 5.08, 0, -1]) cylinder(d=stab_d, h=body_h + 2, $fn=24);

    // 4. PIN 1 WIRE-PINCH CHAMBER (-3.81, +2.54)
    // Terminal 1 connects to the shared Ground Bus Wire
    translate([-3.81, 2.54, 0]) {
        // Conical lead-in funnel on top
        translate([0, 0, body_h - 1.2]) cylinder(d1=1.2, d2=2.6, h=1.3, $fn=24);
        // Vertical pin wedge slot (pin: 0.8x0.3mm)
        translate([0, 0, 1.8]) cube([1.2, 0.9, 3.6], center=true);
        // Slanted spring ramp (15 degrees) that wedges wire against pin
        translate([0.3, 0, 1.6]) rotate([0, 15, 0]) cube([0.7, 1.2, 2.8], center=true);
        // Wire captive retention floor pocket
        translate([0, 0, 0.4]) cube([1.5, 1.4, 1.0], center=true);
    }

    // 5. PIN 2 WIRE-PINCH CHAMBER (+2.54, +5.08)
    // Terminal 2 connects to the Signal Wire (direct to MCU GPIO)
    translate([2.54, 5.08, 0]) {
        // Conical lead-in funnel on top
        translate([0, 0, body_h - 1.2]) cylinder(d1=1.2, d2=2.6, h=1.3, $fn=24);
        // Vertical pin wedge slot
        translate([0, 0, 1.8]) cube([1.2, 0.9, 3.6], center=true);
        // Slanted spring ramp
        translate([-0.3, 0, 1.6]) rotate([0, -15, 0]) cube([0.7, 1.2, 2.8], center=true);
        // Wire captive retention floor pocket
        translate([0, 0, 0.4]) cube([1.5, 1.4, 1.0], center=true);
    }

    // 6. CONTINUOUS GROUND WIRE THREADING TUNNEL (Horizontal along Y = +2.54mm)
    // Passes directly through Pin 1's pinch chamber at Z = 1.6mm
    // 1.0mm diameter tunnel allows smooth threading of 22-24 AWG bare wire
    translate([0, 2.54, 1.6])
        rotate([0, 90, 0])
            cylinder(d=1.1, h=body_w + 5, center=true, $fn=20);
    // Open bottom slit for optional snap-in wire insertion from underneath
    translate([0, 2.54, 0.7])
        cube([body_w + 5, 0.9, 1.5], center=true);

    // 7. SIGNAL WIRE THREADING TUNNEL (Vertical from Pin 2 at X = +2.54mm, exiting +Y)
    // Passes directly through Pin 2's pinch chamber and exits towards top (+Y)
    translate([2.54, 6.4, 1.6])
        rotate([90, 0, 0])
            cylinder(d=1.1, h=5.0, center=true, $fn=20);
    // Open bottom slit for optional snap-in wire insertion
    translate([2.54, 6.4, 0.7])
        cube([0.9, 5.0, 1.5], center=true);
}

// ------------------------------------------------------------------------------
// HELPER GEOMETRY
// ------------------------------------------------------------------------------
module sw_rounded_box(w, l, h, r=1.0) {
    hull() {
        translate([-w/2 + r, -l/2 + r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([ w/2 - r, -l/2 + r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([ w/2 - r,  l/2 - r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([-w/2 + r,  l/2 - r, 0]) cylinder(r=r, h=h, $fn=24);
    }
}

module sw_mounting_tabs(body_w) {
    difference() {
        union() {
            translate([-body_w/2 - 2.5, 0, 0]) sw_rounded_box(5.0, 7.0, 2.4, r=1.0);
            translate([ body_w/2 + 2.5, 0, 0]) sw_rounded_box(5.0, 7.0, 2.4, r=1.0);
        }
        translate([-body_w/2 - 2.5, 0, -1]) cylinder(d=2.2, h=5, $fn=24);
        translate([ body_w/2 + 2.5, 0, -1]) cylinder(d=2.2, h=5, $fn=24);
    }
}

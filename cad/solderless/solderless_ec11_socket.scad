// ==============================================================================
// 100% SOLDERLESS WIRE-PINCH HOTSWAP SOCKET FOR EC11 ROTARY ENCODER
// ==============================================================================
// Zero Soldering! Zero Bought Sockets!
// How it works:
//  - Features 5 precision wire-pinch chambers (3 encoder pins + 2 push switch pins).
//  - You lay bare 22-24 AWG solid copper wire into the captive guide channels.
//  - When you press the EC11 rotary encoder into the socket, all 5 flat metal pins
//    slide down and wedge against the copper wire on internal 15-degree spring ramps,
//    pinching the wire securely against the plastic wall to make solid electrical contact.
//  - Dual anti-torque chassis slots lock the metal tabs against twisting forces!
// ==============================================================================

// Standalone test render if root file
if ($preview && is_undef(is_grid_plate_parent)) {
    solderless_ec11_socket(include_mount_tabs = true);
}

// ------------------------------------------------------------------------------
// POSITIVE STANDALONE MODULE
// ------------------------------------------------------------------------------
module solderless_ec11_socket(
    body_w = 15.4,
    body_l = 15.4,
    body_h = 5.2,
    include_mount_tabs = true,
    clearance = 0.20
) {
    difference() {
        union() {
            ec11_sw_rounded_box(body_w, body_l, body_h, r=1.0);
            if (include_mount_tabs) {
                ec11_sw_mounting_tabs(body_w);
            }
        }
        solderless_ec11_negative(clearance = clearance, body_h = body_h, body_w = body_w, body_l = body_l);
    }
}

// ------------------------------------------------------------------------------
// NEGATIVE CAVITY MODULE (For Standalone Socket & Monolithic Gridplates)
// ------------------------------------------------------------------------------
module solderless_ec11_negative(
    clearance = 0.20,
    body_h = 5.2,
    body_w = 15.4,
    body_l = 15.4
) {
    ec11_w = 12.0 + (clearance * 2);
    ec11_l = 12.0 + (clearance * 2);
    pocket_depth = 2.2;

    enc_pin_y = -5.5;
    sw_pin_y  =  5.0;
    pin_pitch =  2.50; // Pin A (-2.5), C (0.0), B (+2.5)

    // 1. EC11 Main Body Pocket (Top Face)
    translate([0, 0, body_h - pocket_depth])
        translate([0, 0, 0.05])
            ec11_sw_rounded_box(ec11_w, ec11_l, pocket_depth + 0.1, r=0.8);

    // 2. Anti-Torque Chassis Bracket Slots at X = +/- 6.0mm
    translate([-6.0, 0, body_h - pocket_depth - 1.5]) cube([2.2, 1.2, 3.5], center=true);
    translate([ 6.0, 0, body_h - pocket_depth - 1.5]) cube([2.2, 1.2, 3.5], center=true);

    // 3. ENCODER 3-PIN WIRE-PINCH CHAMBERS (Pin A, Common/GND, Pin B at Y = -5.5mm)
    for (i = [-1, 0, 1]) {
        px = i * pin_pitch;
        translate([px, enc_pin_y, 0]) {
            // Funnel lead-in on pocket floor
            translate([0, 0, body_h - pocket_depth - 0.9])
                cylinder(d1=1.2, d2=2.4, h=1.0, $fn=24);
            // Pin wedge cavity
            translate([0, 0, 1.5]) cube([1.1, 0.9, 3.0], center=true);
            // Slanted spring ramp
            translate([0, 0.25, 1.3]) rotate([15, 0, 0]) cube([1.1, 0.6, 2.4], center=true);
        }
    }

    // 4. PUSH SWITCH 2-PIN WIRE-PINCH CHAMBERS (SW1, SW2 at Y = +5.0mm)
    for (sx = [-2.5, 2.5]) {
        translate([sx, sw_pin_y, 0]) {
            // Funnel lead-in
            translate([0, 0, body_h - pocket_depth - 0.9])
                cylinder(d1=1.2, d2=2.4, h=1.0, $fn=24);
            // Pin wedge cavity
            translate([0, 0, 1.5]) cube([1.1, 0.9, 3.0], center=true);
            // Slanted spring ramp
            translate([0, -0.25, 1.3]) rotate([-15, 0, 0]) cube([1.1, 0.6, 2.4], center=true);
        }
    }

    // 5. WIRE THREADING TUNNELS (UNDERSIDE)
    // Common Ground Wire Tunnel: Crosses Center Pin C (0.0, -5.5) and links to SW2 (+2.5, +5.0)
    translate([0, enc_pin_y, 1.4])
        rotate([0, 90, 0]) cylinder(d=1.1, h=body_w + 2, center=true, $fn=20);
    translate([0, enc_pin_y, 0.6]) cube([body_w + 2, 0.9, 1.4], center=true);

    // Push Switch SW1/SW2 Wire Tunnel along Y = +5.0mm
    translate([0, sw_pin_y, 1.4])
        rotate([0, 90, 0]) cylinder(d=1.1, h=body_w + 2, center=true, $fn=20);
    translate([0, sw_pin_y, 0.6]) cube([body_w + 2, 0.9, 1.4], center=true);

    // Ground link tunnel connecting SW2 to Common Ground Pin C
    translate([2.5, 0, 1.4])
        rotate([90, 0, 0]) cylinder(d=1.1, h=12.0, center=true, $fn=20);
    translate([2.5, 0, 0.6]) cube([0.9, 12.0, 1.4], center=true);

    // Encoder Signal A exit tunnel (-Y)
    translate([-2.5, -6.5, 0.6]) cube([0.9, 3.0, 1.4], center=true);

    // Encoder Signal B exit tunnel (-Y)
    translate([ 2.5, -6.5, 0.6]) cube([0.9, 3.0, 1.4], center=true);

    // Push Switch SW1 exit tunnel (+Y)
    translate([-2.5,  6.2, 0.6]) cube([0.9, 3.0, 1.4], center=true);
}

// ------------------------------------------------------------------------------
// HELPER GEOMETRY MODULES
// ------------------------------------------------------------------------------
module ec11_sw_rounded_box(w, l, h, r=1.0) {
    hull() {
        translate([-w/2 + r, -l/2 + r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([ w/2 - r, -l/2 + r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([ w/2 - r,  l/2 - r, 0]) cylinder(r=r, h=h, $fn=24);
        translate([-w/2 + r,  l/2 - r, 0]) cylinder(r=r, h=h, $fn=24);
    }
}

module ec11_sw_mounting_tabs(body_w) {
    difference() {
        union() {
            translate([-body_w/2 - 2.5, 0, 0]) ec11_sw_rounded_box(5.0, 7.0, 2.4, r=1.0);
            translate([ body_w/2 + 2.5, 0, 0]) ec11_sw_rounded_box(5.0, 7.0, 2.4, r=1.0);
        }
        translate([-body_w/2 - 2.5, 0, -1]) cylinder(d=2.2, h=5, $fn=24);
        translate([ body_w/2 + 2.5, 0, -1]) cylinder(d=2.2, h=5, $fn=24);
    }
}

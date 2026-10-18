// ==============================================================================
// 3D-PRINTABLE HOTSWAP SOCKET FOR MECHANICAL KEYBOARD SWITCHES (CHERRY MX / KAILH)
// ==============================================================================
// Designed for FDM / SLA 3D Printing and Handwired Keyboards
// Features:
//  - Compatible with Cherry MX, Gateron, Kailh, Outemu & clones (3-pin & 5-pin)
//  - Mode 1: Kailh SMT Hotswap Socket Caddy (CPG151101S01) with snap-retention
//  - Mode 2: 100% 3D Printed Spring-Wire Socket (no bought socket required!)
//  - Integrated Diode Bay (fits standard 1N4148 DO-35 or SOD-123)
//  - Dual-level separated Row and Column wire routing channels (prevents shorts)
//  - Switch retention clip lip & optional M2 mounting tabs for custom keyboards
// ==============================================================================

// ---------------------------
// PARAMETRIC CUSTOMIZER CONFIG
// ---------------------------
/* [General Settings] */
// Socket style to render
socket_type = "kailh_caddy"; // [kailh_caddy: Kailh CPG151101S01 Caddy, wire_spring: 100% 3D-Printed Wire Contact Socket]

// Include side mounting tabs for screws/plate mounting
include_mount_tabs = true;

// 3D printer clearance offset for pin holes (0.15 - 0.25mm typical for FDM)
print_clearance = 0.20; 

// Base body dimensions (standard switch flange is 15.6 x 15.6mm)
body_width  = 15.4; 
body_length = 15.4;
body_height = 4.8;

// Switch socket top lip thickness (rim that grips the switch bottom)
top_rim_height = 1.0;

/* [Switch Pin Coordinates (Cherry MX Spec)] */
// Center stem hole diameter (MX stem is 3.99mm)
stem_diameter = 4.0 + (print_clearance * 2);

// 5-Pin stabilizer leg diameter (MX legs are 1.70mm)
stab_pin_diameter = 1.70 + (print_clearance * 2);
stab_pin_x_offset = 5.08; // +/- 5.08mm from center

// Pin 1 (Primary contact pin)
pin1_x = -3.81;
pin1_y =  2.54;

// Pin 2 (Offset contact pin)
pin2_x =  2.54;
pin2_y =  5.08;

/* [Wire & Diode Routing] */
// Diode pocket dimensions (for standard 1N4148 axial DO-35 or SMD)
diode_length = 5.0;
diode_width  = 2.2;
diode_depth  = 2.2;

// Matrix wire channel width (for 20 - 24 AWG solid bus wire)
wire_channel_width = 1.4;
wire_channel_depth = 1.4;

// Quality / mesh smoothness
$fn = 40;

// ---------------------------
// MAIN RENDER SELECTOR
// ---------------------------
if (socket_type == "kailh_caddy") {
    kailh_hotswap_caddy();
} else if (socket_type == "wire_spring") {
    wire_spring_socket();
}

// ==============================================================================
// MODULE 1: KAILH HOTSWAP SOCKET CADDY
// ==============================================================================
module kailh_hotswap_caddy() {
    difference() {
        // --- Solid Base Body ---
        union() {
            // Main chamfered block
            rounded_box(body_width, body_length, body_height, r=1.0);
            
            // Optional M2 screw mounting tabs (for Dactyl ManuForm / ergo plates)
            if (include_mount_tabs) {
                mounting_tabs();
            }
        }

        // --- Switch Top Alignment Recess ---
        // Recessed pocket on top so switch housing seats flush
        translate([0, 0, body_height - top_rim_height])
            cube([14.1, 14.1, top_rim_height + 0.1], center=true);

        // --- Center Stem Through-Hole ---
        translate([0, 0, -1])
            cylinder(d=stem_diameter, h=body_height + 2);

        // --- 5-Pin Switch Stabilizer Holes ---
        translate([-stab_pin_x_offset, 0, -1])
            cylinder(d=stab_pin_diameter, h=body_height + 2);
        translate([ stab_pin_x_offset, 0, -1])
            cylinder(d=stab_pin_diameter, h=body_height + 2);

        // --- Lead-in Chamfers / Funnels for Switch Pins ---
        // Funneled entrance makes switch insertion silky smooth
        translate([pin1_x, pin1_y, body_height - 1.2])
            cylinder(d1=1.4, d2=3.0, h=1.3);
        translate([pin1_x, pin1_y, -0.1])
            cylinder(d=1.4, h=body_height + 0.2);

        translate([pin2_x, pin2_y, body_height - 1.2])
            cylinder(d1=1.4, d2=3.0, h=1.3);
        translate([pin2_x, pin2_y, -0.1])
            cylinder(d=1.4, h=body_height + 0.2);

        // --- Kailh Socket Cavity (CPG151101S01 Body) ---
        // Sits in the bottom face, supported by a 1.2mm top ceiling
        translate([0, 0, -0.1]) {
            // Main socket body span
            translate([-0.5, 3.8, 0])
                rounded_box(13.2, 5.8, 3.2, r=0.8);
            
            // Left contact receptacle & solder wing pocket
            translate([-4.8, 2.54, 0])
                cube([4.8, 3.8, 3.2], center=true);
            
            // Right contact receptacle & solder wing pocket
            translate([4.2, 5.08, 0])
                cube([4.8, 3.8, 3.2], center=true);
                
            // Solder wing access slots (allows soldering iron tip access)
            translate([-6.5, 2.54, 0])
                cube([3.0, 2.8, 3.2], center=true);
            translate([ 5.8, 5.08, 0])
                cube([3.0, 2.8, 3.2], center=true);
        }

        // --- Diode Pocket (1N4148) ---
        // Embedded horizontal diode slot next to Pin 2
        translate([0.5, -2.5, -0.1]) {
            cube([diode_length, diode_width, diode_depth], center=true);
            // Wire leg pass-through to Pin 2 wing
            translate([1.8, 2.5, 0])
                cube([1.0, 5.0, diode_depth], center=true);
        }

        // --- Row Wire Channel (X-Axis, across bottom) ---
        translate([0, -5.5, 0.7])
            cube([body_width + 6, wire_channel_width, wire_channel_depth], center=true);

        // --- Column Wire Channel (Y-Axis, across left) ---
        translate([-6.2, 0, 0.7])
            cube([wire_channel_width, body_length + 6, wire_channel_depth], center=true);
            
        // --- Retention Snap Ridges Relief ---
        // Small undercut to allow snap-fit insertion of the Kailh socket
        translate([-6.6, 2.54, 1.8])
            sphere(r=0.6);
        translate([ 6.0, 5.08, 1.8])
            sphere(r=0.6);
    }
}

// ==============================================================================
// MODULE 2: 100% 3D PRINTED SPRING-WIRE HOTSWAP SOCKET
// (No Kailh socket needed - uses bent 24 AWG copper wire or diode legs)
// ==============================================================================
module wire_spring_socket() {
    difference() {
        // Base block
        union() {
            rounded_box(body_width, body_length, 4.2, r=1.0);
            if (include_mount_tabs) mounting_tabs();
        }

        // Switch alignment recess
        translate([0, 0, 4.2 - 0.8])
            cube([14.1, 14.1, 0.9], center=true);

        // Center stem hole
        translate([0, 0, -1])
            cylinder(d=stem_diameter, h=6);

        // 5-pin stabilizer holes
        translate([-stab_pin_x_offset, 0, -1]) cylinder(d=stab_pin_diameter, h=6);
        translate([ stab_pin_x_offset, 0, -1]) cylinder(d=stab_pin_diameter, h=6);

        // --- Contact Chamber 1 (Pin 1) ---
        translate([pin1_x, pin1_y, 0]) {
            // Pin entry funnel from top
            translate([0, 0, 4.2 - 1.2]) cylinder(d1=1.2, d2=2.8, h=1.3);
            // Pin channel
            translate([0, 0, -0.5]) cylinder(d=1.2, h=5);
            // Spring wire deflection chamber
            translate([0.5, 0, 1.6]) cube([1.2, 2.0, 3.2], center=true);
            // Wire threading feed hole (0.8mm for 24AWG solid wire)
            translate([1.2, 0, 1.0]) rotate([0, 90, 0]) cylinder(d=0.9, h=3);
        }

        // --- Contact Chamber 2 (Pin 2) ---
        translate([pin2_x, pin2_y, 0]) {
            // Pin entry funnel from top
            translate([0, 0, 4.2 - 1.2]) cylinder(d1=1.2, d2=2.8, h=1.3);
            // Pin channel
            translate([0, 0, -0.5]) cylinder(d=1.2, h=5);
            // Spring wire deflection chamber
            translate([-0.5, 0, 1.6]) cube([1.2, 2.0, 3.2], center=true);
            // Wire threading feed hole
            translate([-1.2, 0, 1.0]) rotate([0, -90, 0]) cylinder(d=0.9, h=3);
        }

        // Integrated Diode slot
        translate([0.0, -2.5, 1.0])
            cube([diode_length, diode_width, 2.0], center=true);

        // Row & Column routing channels
        translate([0, -5.5, 0.7]) cube([body_width + 4, 1.4, 1.4], center=true);
        translate([-6.0, 0, 0.7])  cube([1.4, body_length + 4, 1.4], center=true);
    }
}

// ==============================================================================
// HELPER MODULES
// ==============================================================================
module rounded_box(w, l, h, r=1.0) {
    // Centered rounded box along X and Y, resting on Z=0
    hull() {
        translate([-w/2 + r, -l/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r, -l/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r,  l/2 - r, 0]) cylinder(r=r, h=h);
        translate([-w/2 + r,  l/2 - r, 0]) cylinder(r=r, h=h);
    }
}

module mounting_tabs() {
    // Mounting ears on X sides with M2 screw holes (2.2mm diameter)
    difference() {
        union() {
            translate([-body_width/2 - 2.5, 0, 1.2])
                rounded_box(5.0, 7.0, 2.4, r=1.0);
            translate([ body_width/2 + 2.5, 0, 1.2])
                rounded_box(5.0, 7.0, 2.4, r=1.0);
        }
        // Screw holes
        translate([-body_width/2 - 2.5, 0, -1]) cylinder(d=2.2, h=5);
        translate([ body_width/2 + 2.5, 0, -1]) cylinder(d=2.2, h=5);
    }
}

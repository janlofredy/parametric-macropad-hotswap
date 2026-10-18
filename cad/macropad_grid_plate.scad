// ==============================================================================
// PARAMETRIC MONOLITHIC MACROPAD GRIDPLATE WITH MCU ENDPOINT TERMINAL DOCK
// ==============================================================================
// Features:
//  - 100% Hotswap for Switches and EC11 Rotary Encoder (NEVER solder to switches/encoder!)
//  - Dedicated MCU Endpoint Terminal Dock on the top edge
//  - Built-in 2.54mm (0.1") pin-header receptacle strip for easy microcontroller connection
//  - All signal and Ground bus wires route through organized underside trenches
//    directly into the endpoint terminal dock!
//  - Compatible with direct MCU mounting (RP2040-Zero, Pro Micro, Seeed Xiao, etc.)
// ==============================================================================

is_grid_plate_parent = true;

// Include modular socket definitions
include <keyboard_switch_socket.scad>
include <ec11_hotswap_socket.scad>

// ------------------------------------------------------------------------------
// PARAMETRIC CONFIGURATION
// ------------------------------------------------------------------------------
/* [Grid Dimensions] */
rows = 3; // [1:10]
cols = 3; // [1:10]
pitch = 19.05; // Standard Cherry MX key pitch (19.05mm)
plate_h = 5.2; // Plate thickness (matches hotswap caddy depth)

// Perimeter border margins
border_margin_x = 4.0;
border_margin_bottom = 4.0;

// Extra top margin to host the dedicated MCU Endpoint Terminal Dock
mcu_dock_depth = 22.0; 
corner_r = 3.0;

/* [Encoder Placement] */
// [row, col] -> [[0, 2]] places knob in top-right corner
encoder_locations = [
    [0, 2]
];

/* [Endpoint Terminal Dock Settings] */
// Number of terminal pins in header (GND + Keys + Encoder pins)
num_terminals = 12; // e.g. 1 GND + 8 Keys + 3 Encoder (A, B, SW)
terminal_pitch = 2.54; // Standard 0.1" (2.54mm) pin header pitch
terminal_hole_d = 1.6; // Fits standard 2.54mm male/female header pins

// Microcontroller bay dimensions (for direct MCU nesting e.g. RP2040-Zero / Pro Micro)
include_mcu_pocket = true;
mcu_pocket_w = 26.0;
mcu_pocket_l = 19.0;
mcu_pocket_depth = 3.0;
usb_cutout_w = 12.0;

/* [Mounting Screws] */
mount_hole_d = 2.2; // M2 screws
mount_hole_inset = 2.5;

clearance = 0.20;
$fn = 36;

// ------------------------------------------------------------------------------
// MAIN RENDER
// ------------------------------------------------------------------------------
macropad_with_endpoint_dock(
    rows = rows,
    cols = cols,
    pitch = pitch,
    plate_h = plate_h,
    border_margin_x = border_margin_x,
    border_margin_bottom = border_margin_bottom,
    mcu_dock_depth = mcu_dock_depth,
    corner_r = corner_r,
    encoder_coords = encoder_locations,
    num_terminals = num_terminals,
    terminal_pitch = terminal_pitch,
    include_mcu_pocket = include_mcu_pocket,
    clearance = clearance
);

// ==============================================================================
// MODULE: MONOLITHIC GRIDPLATE WITH MCU ENDPOINT DOCK
// ==============================================================================
module macropad_with_endpoint_dock(
    rows = 3,
    cols = 3,
    pitch = 19.05,
    plate_h = 5.2,
    border_margin_x = 4.0,
    border_margin_bottom = 4.0,
    mcu_dock_depth = 22.0,
    corner_r = 3.0,
    encoder_coords = [[0, 2]],
    num_terminals = 12,
    terminal_pitch = 2.54,
    include_mcu_pocket = true,
    clearance = 0.20
) {
    // Total plate dimensions including the MCU dock on top
    total_w = (cols * pitch) + (border_margin_x * 2);
    grid_l  = (rows * pitch);
    total_l = grid_l + border_margin_bottom + mcu_dock_depth;

    // Grid center reference
    start_x = -((cols - 1) * pitch) / 2;
    // Offset grid so MCU dock sits neatly on top
    grid_center_y = -mcu_dock_depth / 2 + border_margin_bottom / 2;
    start_y = grid_center_y + ((rows - 1) * pitch) / 2;

    dock_center_y = (total_l / 2) - (mcu_dock_depth / 2);

    difference() {
        // --- 1. Monolithic Base Plate with Top MCU Extension ---
        grid_dock_box(total_w, total_l, plate_h, r=corner_r);

        // --- 2. Corner M2 Mounting Holes ---
        corner_x = (total_w / 2) - mount_hole_inset;
        corner_y = (total_l / 2) - mount_hole_inset;
        for (mx = [-corner_x, corner_x]) {
            for (my = [-corner_y, corner_y]) {
                translate([mx, my, -1])
                    cylinder(d=mount_hole_d, h=plate_h + 2);
            }
        }

        // --- 3. Switch & Encoder Hotswap Socket Bays ---
        for (r = [0 : rows - 1]) {
            for (c = [0 : cols - 1]) {
                pos_x = start_x + (c * pitch);
                pos_y = start_y - (r * pitch);

                is_encoder = check_is_encoder(r, c, encoder_coords);

                translate([pos_x, pos_y, 0]) {
                    if (is_encoder) {
                        ec11_socket_negative(
                            clearance = clearance,
                            body_h = plate_h,
                            include_diode = false
                        );
                    } else {
                        mx_socket_negative(
                            clearance = clearance,
                            body_h = plate_h,
                            include_diode = false
                        );
                    }
                }
            }

            // Continuous Horizontal GND Bus Trench across Terminal 1 (Y = +2.54mm)
            row_ground_y = start_y - (r * pitch) + 2.54;
            translate([0, row_ground_y, 0.7])
                cube([total_w - (border_margin_x * 2) + 2, 1.5, 1.4], center=true);
        }

        // --- 4. Main Ground Bus Trunk Line to MCU Dock ---
        // Vertical trunk linking all row Ground wires directly up to the MCU dock GND terminal
        translate([-total_w/2 + 6.0, 0, 0.7])
            cube([1.5, total_l - 12.0, 1.4], center=true);

        // --- 5. Individual Signal Wire Routing Trenches to Dock ---
        // Each switch column has an organized wire duct heading up to the terminal bay
        for (c = [0 : cols - 1]) {
            col_signal_x = start_x + (c * pitch) + 5.8;
            translate([col_signal_x, (total_l / 4), 0.7])
                cube([1.4, total_l / 2, 1.4], center=true);
        }

        // --- 6. DEDICATED MCU ENDPOINT TERMINAL DOCK (TOP EDGE) ---
        translate([0, dock_center_y, 0]) {
            // Optional recessed MCU cradle pocket (fits RP2040-Zero, Xiao, Pro Micro)
            if (include_mcu_pocket) {
                // MCU PCB seating recess
                translate([0, 0, plate_h - mcu_pocket_depth + 0.1])
                    cube([mcu_pocket_w, mcu_pocket_l, mcu_pocket_depth + 0.2], center=true);
                
                // USB-C connector cutout (flush pass-through to edge)
                translate([0, mcu_dock_depth/2 - 2.0, plate_h - 2.0])
                    cube([usb_cutout_w, 8.0, 4.0], center=true);
            }

            // Universal 2.54mm Endpoint Pin Terminal Array
            // 1 row of pin receptacles where all matrix wires terminate
            terminal_start_x = -((num_terminals - 1) * terminal_pitch) / 2;
            for (t = [0 : num_terminals - 1]) {
                tx = terminal_start_x + (t * terminal_pitch);
                
                // 2.54mm Pin through-hole (fits male/female header pin or bare wire insertion)
                translate([tx, -mcu_pocket_l/2 + 3.0, -1])
                    cylinder(d=terminal_hole_d, h=plate_h + 2, $fn=24);
                
                // Lead-in funnel on top
                translate([tx, -mcu_pocket_l/2 + 3.0, plate_h - 1.2])
                    cylinder(d1=terminal_hole_d, d2=2.4, h=1.3, $fn=24);
                
                // Underside wire entry pocket (where you solder wire to pin header or push-fit)
                translate([tx, -mcu_pocket_l/2 + 3.0, 0.7])
                    cube([terminal_hole_d + 0.6, 2.4, 1.4], center=true);
            }

            // Underside wire feed trench into the terminal array
            translate([0, -mcu_pocket_l/2 + 3.0, 0.7])
                cube([(num_terminals * terminal_pitch) + 2, 1.5, 1.4], center=true);
        }
    }
}

function check_is_encoder(r, c, coords, idx = 0) =
    (idx >= len(coords)) ? false :
    (coords[idx][0] == r && coords[idx][1] == c) ? true :
    check_is_encoder(r, c, coords, idx + 1);

module grid_dock_box(w, l, h, r=3.0) {
    hull() {
        translate([-w/2 + r, -l/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r, -l/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r,  l/2 - r, 0]) cylinder(r=r, h=h);
        translate([-w/2 + r,  l/2 - r, 0]) cylinder(r=r, h=h);
    }
}

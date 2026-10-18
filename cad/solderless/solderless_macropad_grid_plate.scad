// ==============================================================================
// 100% SOLDERLESS PARAMETRIC MONOLITHIC MACROPAD GRIDPLATE
// ==============================================================================
// Zero Soldering! Zero Bought Kailh Sockets! Zero Diodes!
// Combines 100% 3D-printable wire-pinch mechanical switch sockets and EC11 encoder
// sockets into an unbroken monolithic midplate / switchplate.
// ==============================================================================

is_grid_plate_parent = true;

// Include solderless modular sub-components
include <solderless_switch_socket.scad>
include <solderless_ec11_socket.scad>

// ------------------------------------------------------------------------------
// PARAMETRIC MACROPAD CONFIGURATION
// ------------------------------------------------------------------------------
/* [Grid Dimensions] */
rows = 3; // [1:10]
cols = 3; // [1:10]

// Standard mechanical keyboard keycap pitch (19.05mm)
pitch = 19.05;

// Monolithic plate thickness
plate_h = 5.2;

// Perimeter border margin around the outer switches
border_margin = 4.0;

// Corner rounding radius for the outer plate
corner_r = 3.0;

/* [Encoder Placement] */
// Locations where an EC11 Rotary Encoder replaces a key switch
// [row, col] -> [[0, 2]] places knob in top-right corner of 3x3
encoder_locations = [
    [0, 2]
];

/* [Mounting Screws] */
mount_hole_d = 2.2; // M2 screws
mount_hole_inset = 2.5;

clearance = 0.20;
$fn = 36;

// ------------------------------------------------------------------------------
// MAIN RENDER
// ------------------------------------------------------------------------------
solderless_macropad_grid_plate(
    rows = rows,
    cols = cols,
    pitch = pitch,
    plate_h = plate_h,
    border_margin = border_margin,
    corner_r = corner_r,
    encoder_coords = encoder_locations,
    clearance = clearance
);

// ==============================================================================
// MODULE: SOLDERLESS MONOLITHIC GRIDPLATE
// ==============================================================================
module solderless_macropad_grid_plate(
    rows = 3,
    cols = 3,
    pitch = 19.05,
    plate_h = 5.2,
    border_margin = 4.0,
    corner_r = 3.0,
    encoder_coords = [[0, 2]],
    clearance = 0.20
) {
    total_w = (cols * pitch) + (border_margin * 2);
    total_l = (rows * pitch) + (border_margin * 2);

    start_x = -((cols - 1) * pitch) / 2;
    start_y =  ((rows - 1) * pitch) / 2;

    difference() {
        // --- 1. Monolithic Base Plate ---
        solderless_grid_box(total_w, total_l, plate_h, r=corner_r);

        // --- 2. Corner M2 Mounting Holes ---
        corner_x = (total_w / 2) - mount_hole_inset;
        corner_y = (total_l / 2) - mount_hole_inset;
        for (mx = [-corner_x, corner_x]) {
            for (my = [-corner_y, corner_y]) {
                translate([mx, my, -1])
                    cylinder(d=mount_hole_d, h=plate_h + 2);
            }
        }

        // --- 3. Solderless Wire-Pinch Sockets ---
        for (r = [0 : rows - 1]) {
            for (c = [0 : cols - 1]) {
                pos_x = start_x + (c * pitch);
                pos_y = start_y - (r * pitch);

                is_encoder = check_is_encoder(r, c, encoder_coords);

                translate([pos_x, pos_y, 0]) {
                    if (is_encoder) {
                        solderless_ec11_negative(
                            clearance = clearance,
                            body_h = plate_h
                        );
                    } else {
                        solderless_switch_negative(
                            clearance = clearance,
                            body_h = plate_h
                        );
                    }
                }
            }

            // Continuous Horizontal Ground Wire Tunnel across each row at Y = +2.54mm
            // Allows threading a single straight 22-24 AWG wire through all Pin 1 chambers!
            row_ground_y = start_y - (r * pitch) + 2.54;
            translate([0, row_ground_y, 1.6])
                rotate([0, 90, 0])
                    cylinder(d=1.1, h=total_w - (border_margin * 2) + 4, center=true, $fn=20);
            translate([0, row_ground_y, 0.7])
                cube([total_w - (border_margin * 2) + 4, 0.9, 1.5], center=true);
        }
    }
}

function check_is_encoder(r, c, coords, idx = 0) =
    (idx >= len(coords)) ? false :
    (coords[idx][0] == r && coords[idx][1] == c) ? true :
    check_is_encoder(r, c, coords, idx + 1);

module solderless_grid_box(w, l, h, r=3.0) {
    hull() {
        translate([-w/2 + r, -l/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r, -l/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r,  l/2 - r, 0]) cylinder(r=r, h=h);
        translate([-w/2 + r,  l/2 - r, 0]) cylinder(r=r, h=h);
    }
}

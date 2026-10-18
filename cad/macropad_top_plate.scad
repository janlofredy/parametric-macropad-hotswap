// ==============================================================================
// PARAMETRIC MACROPAD TOP PLATE (SWITCH & ROTARY ENCODER MOUNTING PLATE)
// ==============================================================================
// Designed to pair with `macropad_grid_plate.scad` and `macropad_bottom_plate.scad`
// Features:
//  - Standard Cherry MX switch cutouts (14.0 x 14.0mm) with side clip relief notches
//  - EC11 Rotary Encoder shaft pass-through collar (fits standard M7 bushing)
//  - M2 corner screw pass-through holes aligning with the midplate & bottom case
//  - Clean perimeter bevel and optional top status window
// ==============================================================================

// ------------------------------------------------------------------------------
// PARAMETRIC CONFIGURATION
// ------------------------------------------------------------------------------
/* [Grid Dimensions] */
rows = 3; // [1:10]
cols = 3; // [1:10]
pitch = 19.05; // Standard Cherry MX key pitch (19.05mm)

// Plate thickness: Standard MX switch latch plate is 1.5mm (or 3.0mm with clip lip)
top_plate_h = 2.0;

// Perimeter border margins (must match macropad_grid_plate.scad)
border_margin_x = 4.0;
border_margin_bottom = 4.0;
mcu_dock_depth = 22.0; 
corner_r = 3.0;

/* [Encoder Placement] */
// [row, col] -> [[0, 2]] places knob in top-right corner
encoder_locations = [
    [0, 2]
];

/* [Switch Cutout Specs] */
// Standard Cherry MX plate cutout is 14.0mm x 14.0mm
switch_cutout_size = 14.0;
// Side relief notches for switch retention clips (0.8mm x 4.0mm on top/bottom edges)
include_clip_notches = true;

// EC11 Bushing collar hole diameter (7.5mm for standard M7 threaded bushing)
encoder_hole_d = 7.5;

/* [Mounting Screws] */
mount_hole_d = 2.4; // M2 screw clear pass-through (2.4mm)
mount_hole_inset = 2.5;

// MCU Status / OLED / Reset window on top dock (optional)
include_mcu_window = false;
mcu_window_w = 20.0;
mcu_window_l = 14.0;

$fn = 36;

// ------------------------------------------------------------------------------
// MAIN RENDER
// ------------------------------------------------------------------------------
macropad_top_plate(
    rows = rows,
    cols = cols,
    pitch = pitch,
    top_plate_h = top_plate_h,
    border_margin_x = border_margin_x,
    border_margin_bottom = border_margin_bottom,
    mcu_dock_depth = mcu_dock_depth,
    corner_r = corner_r,
    encoder_coords = encoder_locations,
    switch_cutout_size = switch_cutout_size,
    encoder_hole_d = encoder_hole_d,
    include_clip_notches = include_clip_notches,
    include_mcu_window = include_mcu_window
);

// ==============================================================================
// MODULE: MACROPAD TOP PLATE
// ==============================================================================
module macropad_top_plate(
    rows = 3,
    cols = 3,
    pitch = 19.05,
    top_plate_h = 2.0,
    border_margin_x = 4.0,
    border_margin_bottom = 4.0,
    mcu_dock_depth = 22.0,
    corner_r = 3.0,
    encoder_coords = [[0, 2]],
    switch_cutout_size = 14.0,
    encoder_hole_d = 7.5,
    include_clip_notches = true,
    include_mcu_window = false
) {
    total_w = (cols * pitch) + (border_margin_x * 2);
    grid_l  = (rows * pitch);
    total_l = grid_l + border_margin_bottom + mcu_dock_depth;

    start_x = -((cols - 1) * pitch) / 2;
    grid_center_y = -mcu_dock_depth / 2 + border_margin_bottom / 2;
    start_y = grid_center_y + ((rows - 1) * pitch) / 2;

    dock_center_y = (total_l / 2) - (mcu_dock_depth / 2);

    difference() {
        // --- 1. Solid Top Plate Outline ---
        top_plate_box(total_w, total_l, top_plate_h, r=corner_r);

        // --- 2. Corner M2 Screw Pass-Through Holes ---
        corner_x = (total_w / 2) - mount_hole_inset;
        corner_y = (total_l / 2) - mount_hole_inset;
        for (mx = [-corner_x, corner_x]) {
            for (my = [-corner_y, corner_y]) {
                translate([mx, my, -1])
                    cylinder(d=mount_hole_d, h=top_plate_h + 2);
            }
        }

        // --- 3. Grid Cutouts (Switches and Rotary Encoders) ---
        for (r = [0 : rows - 1]) {
            for (c = [0 : cols - 1]) {
                pos_x = start_x + (c * pitch);
                pos_y = start_y - (r * pitch);

                is_encoder = check_is_encoder_top(r, c, encoder_coords);

                translate([pos_x, pos_y, 0]) {
                    if (is_encoder) {
                        // EC11 Rotary Encoder Collar Pass-Through
                        translate([0, 0, -1])
                            cylinder(d=encoder_hole_d, h=top_plate_h + 2, $fn=32);
                    } else {
                        // Standard Cherry MX 14.0mm Square Cutout
                        translate([0, 0, -1])
                            cube([switch_cutout_size, switch_cutout_size, top_plate_h + 2], center=true);

                        // Side clip relief notches for switch retention latches
                        if (include_clip_notches) {
                            translate([0,  switch_cutout_size/2 + 0.3, -1])
                                cube([4.5, 1.2, top_plate_h + 2], center=true);
                            translate([0, -switch_cutout_size/2 - 0.3, -1])
                                cube([4.5, 1.2, top_plate_h + 2], center=true);
                        }
                    }
                }
            }
        }

        // --- 4. Optional Top MCU Viewing / Reset Window ---
        if (include_mcu_window) {
            translate([0, dock_center_y, -1])
                cube([mcu_window_w, mcu_window_l, top_plate_h + 2], center=true);
        }
    }
}

function check_is_encoder_top(r, c, coords, idx = 0) =
    (idx >= len(coords)) ? false :
    (coords[idx][0] == r && coords[idx][1] == c) ? true :
    check_is_encoder_top(r, c, coords, idx + 1);

module top_plate_box(w, l, h, r=3.0) {
    hull() {
        translate([-w/2 + r, -l/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r, -l/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r,  l/2 - r, 0]) cylinder(r=r, h=h);
        translate([-w/2 + r,  l/2 - r, 0]) cylinder(r=r, h=h);
    }
}

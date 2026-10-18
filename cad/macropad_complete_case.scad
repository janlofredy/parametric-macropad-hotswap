// ==============================================================================
// PARAMETRIC MACROPAD COMPLETE ASSEMBLY (TOP PLATE + MIDPLATE + BOTTOM CASE)
// ==============================================================================
// Visualizes the complete 3-layer macropad sandwich assembly with exploded view!
// ==============================================================================

include <macropad_top_plate.scad>
include <macropad_grid_plate.scad>
include <macropad_bottom_plate.scad>

// ------------------------------------------------------------------------------
// ASSEMBLY CONFIGURATION
// ------------------------------------------------------------------------------
/* [Assembly View] */
// Exploded view slider: 0 = fully assembled sandwich, 100 = fully exploded
explode = 30; // [0:100]

/* [Microcontroller Type] */
mcu = "esp32_devkit"; // [esp32_devkit, esp32_s2_mini, esp32_c3_xiao, rp2040_zero, pro_micro, pi_pico]

/* [Grid Dimensions] */
macropad_rows = 3;
macropad_cols = 3;
macropad_pitch = 19.05;

// Layer heights
top_h = 2.0;
mid_h = 5.2;
bot_h = 9.0;

// Exploded offsets
z_gap = explode * 0.4;

// ------------------------------------------------------------------------------
// RENDER FULL SANDWICH ASSEMBLY
// ------------------------------------------------------------------------------
// 1. Bottom Case Tray (Charcoal / Dark Slate)
color([0.15, 0.18, 0.24])
    macropad_bottom_plate(
        mcu_type = mcu,
        rows = macropad_rows,
        cols = macropad_cols,
        pitch = macropad_pitch,
        case_height = bot_h
    );

// 2. Monolithic Mid Gridplate (Translucent Indigo / Blue)
color([0.25, 0.35, 0.85, 0.9])
    translate([0, 0, bot_h + z_gap])
        macropad_with_endpoint_dock(
            rows = macropad_rows,
            cols = macropad_cols,
            pitch = macropad_pitch,
            plate_h = mid_h
        );

// 3. Top Switch Plate (Frosted Titanium / Light Grey)
color([0.75, 0.80, 0.88, 0.95])
    translate([0, 0, bot_h + mid_h + (z_gap * 2)])
        macropad_top_plate(
            rows = macropad_rows,
            cols = macropad_cols,
            pitch = macropad_pitch,
            top_plate_h = top_h
        );

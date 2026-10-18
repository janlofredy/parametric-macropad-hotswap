// ==============================================================================
// PARAMETRIC MACROPAD BOTTOM PLATE / CASE TRAY
// ==============================================================================
// Features:
//  - Dedicated mounting options for common microcontrollers (ESP32, RP2040, Pro Micro, Pico)
//  - Specifically optimized for ESP32 DevKit / S2-S3 Mini / XIAO ESP32
//  - Deep wiring cavity so underside wires never get crushed or pinched
//  - USB port pass-through cutout matched to MCU height
//  - 4x Recessed rubber foot pockets (for 8mm silicone anti-slip pads)
//  - Corner M2 mounting holes (supports M2 heat-set inserts or direct screws)
// ==============================================================================

// ------------------------------------------------------------------------------
// PARAMETRIC CONFIGURATION
// ------------------------------------------------------------------------------
/* [Microcontroller Selection] */
// Choose your microcontroller board:
// "esp32_devkit"  : Standard ESP32 NodeMCU / DevKit V1 (30/38 pin)
// "esp32_s2_mini" : Lolin / Wemos ESP32-S2 / S3 Mini (USB-C)
// "esp32_c3_xiao" : Seeed Studio XIAO ESP32-C3 / S3 (Ultra compact)
// "rp2040_zero"   : Waveshare RP2040-Zero (USB-C)
// "pro_micro"     : Standard Pro Micro (ATmega32U4 / RP2040)
// "pi_pico"       : Raspberry Pi Pico / Pico W
// "universal"     : Open pocket for any custom MCU or battery
mcu_type = "esp32_devkit"; // [esp32_devkit, esp32_s2_mini, esp32_c3_xiao, rp2040_zero, pro_micro, pi_pico, universal]

/* [Grid Dimensions (Must match midplate)] */
rows = 3;
cols = 3;
pitch = 19.05;

border_margin_x = 4.0;
border_margin_bottom = 4.0;
mcu_dock_depth = 22.0; 
corner_r = 3.0;

/* [Enclosure Case Dimensions] */
// Total outer height of bottom tray
case_height = 9.0;
// Internal floor thickness
floor_thickness = 2.0;
// Perimeter wall thickness
wall_thickness = 2.4;

// Ergonomic tilt angle (0 for flat desk profile, 5 to 7 degrees for tilt)
tilt_angle = 0; // [0:15]

/* [Mounting & Hardware] */
// Corner screw type: "heatset_insert" (M2 brass threaded insert, 3.2mm) or "through_screw" (2.2mm)
insert_type = "heatset_insert"; // [heatset_insert, through_screw]
mount_hole_inset = 2.5;

// Anti-slip rubber foot pockets on underside (8mm round silicone pads)
include_rubber_feet = true;
foot_diameter = 8.2;
foot_depth = 1.0;

$fn = 36;

// ------------------------------------------------------------------------------
// MAIN RENDER
// ------------------------------------------------------------------------------
macropad_bottom_plate(
    mcu_type = mcu_type,
    rows = rows,
    cols = cols,
    pitch = pitch,
    case_height = case_height,
    floor_thickness = floor_thickness,
    wall_thickness = wall_thickness,
    border_margin_x = border_margin_x,
    border_margin_bottom = border_margin_bottom,
    mcu_dock_depth = mcu_dock_depth,
    corner_r = corner_r,
    insert_type = insert_type,
    include_rubber_feet = include_rubber_feet
);

// ==============================================================================
// MODULE: MACROPAD BOTTOM PLATE
// ==============================================================================
module macropad_bottom_plate(
    mcu_type = "esp32_devkit",
    rows = 3,
    cols = 3,
    pitch = 19.05,
    case_height = 9.0,
    floor_thickness = 2.0,
    wall_thickness = 2.4,
    border_margin_x = 4.0,
    border_margin_bottom = 4.0,
    mcu_dock_depth = 22.0,
    corner_r = 3.0,
    insert_type = "heatset_insert",
    include_rubber_feet = true
) {
    total_w = (cols * pitch) + (border_margin_x * 2);
    grid_l  = (rows * pitch);
    total_l = grid_l + border_margin_bottom + mcu_dock_depth;

    internal_w = total_w - (wall_thickness * 2);
    internal_l = total_l - (wall_thickness * 2);
    cavity_depth = case_height - floor_thickness;

    dock_center_y = (total_l / 2) - (mcu_dock_depth / 2);

    hole_d = (insert_type == "heatset_insert") ? 3.2 : 2.2; // 3.2mm for M2 brass heatset insert

    difference() {
        // --- 1. Outer Solid Base Tray ---
        bottom_hull_box(total_w, total_l, case_height, r=corner_r);

        // --- 2. Main Internal Wiring & Component Cavity ---
        translate([0, 0, floor_thickness + cavity_depth/2 + 0.1])
            bottom_hull_box(internal_w, internal_l, cavity_depth + 0.2, r=max(0.5, corner_r - wall_thickness));

        // --- 3. Corner Mounting Screw / Heatset Insert Holes ---
        corner_x = (total_w / 2) - mount_hole_inset;
        corner_y = (total_l / 2) - mount_hole_inset;
        for (mx = [-corner_x, corner_x]) {
            for (my = [-corner_y, corner_y]) {
                // Hole extending from top of case down
                translate([mx, my, floor_thickness - 0.5])
                    cylinder(d=hole_d, h=case_height + 2);
            }
        }

        // --- 4. USB Port Cutout on Top/Back Wall ---
        mcu_usb_spec = get_mcu_usb_spec(mcu_type);
        usb_w = mcu_usb_spec[0];
        usb_h = mcu_usb_spec[1];
        usb_z_offset = mcu_usb_spec[2];

        translate([0, total_l/2 - wall_thickness/2, floor_thickness + usb_z_offset + usb_h/2])
            cube([usb_w, wall_thickness + 2, usb_h], center=true);

        // --- 5. Rubber Anti-Slip Foot Recesses (Underside) ---
        if (include_rubber_feet) {
            foot_x = (total_w / 2) - 8.0;
            foot_y = (total_l / 2) - 8.0;
            for (fx = [-foot_x, foot_x]) {
                for (fy = [-foot_y, foot_y]) {
                    translate([fx, fy, -0.1])
                        cylinder(d=foot_diameter, h=foot_depth + 0.1, $fn=32);
                }
            }
        }
    }

    // --- 6. ADDITIVE MCU CRADLE & STANDOFF SUPPORTS ---
    translate([0, dock_center_y, 0]) {
        render_mcu_cradle(mcu_type, floor_thickness, cavity_depth);
    }
}

// ------------------------------------------------------------------------------
// MCU SPECIFICATIONS & STANDOFF GENERATOR
// ------------------------------------------------------------------------------
// Returns [usb_width, usb_height, usb_z_offset_from_floor]
function get_mcu_usb_spec(type) =
    (type == "esp32_devkit")  ? [12.0, 7.0, 2.5] : // ESP32 DevKit USB-C / micro
    (type == "esp32_s2_mini") ? [11.5, 6.5, 2.2] : // ESP32-S2 Mini USB-C
    (type == "esp32_c3_xiao") ? [11.0, 6.0, 1.8] : // Seeed Xiao USB-C
    (type == "rp2040_zero")   ? [11.0, 6.0, 1.8] : // RP2040-Zero USB-C
    (type == "pro_micro")     ? [10.5, 6.0, 2.0] : // Pro Micro USB
    (type == "pi_pico")       ? [11.5, 6.5, 2.2] : // Pi Pico USB
    [12.0, 7.0, 2.5]; // Universal

module render_mcu_cradle(type, floor_h, cav_depth) {
    if (type == "esp32_devkit") {
        // Standard ESP32 DevKit V1 Cradle (Width 25.4 - 26.0mm, Length 48.0 - 52.0mm)
        // Standoff support rails on sides
        standoff_h = 2.5;
        translate([-13.0, 0, floor_h + standoff_h/2])
            cube([2.0, 30.0, standoff_h], center=true);
        translate([ 13.0, 0, floor_h + standoff_h/2])
            cube([2.0, 30.0, standoff_h], center=true);
        // Small retention edge stops
        translate([0, -15.5, floor_h + 1.2])
            cube([24.0, 1.5, 2.4], center=true);
    } else if (type == "esp32_s2_mini") {
        // Wemos / Lolin S2-S3 Mini (Width 25.4mm, Length 34.3mm)
        standoff_h = 2.2;
        translate([-12.7, 0, floor_h + standoff_h/2]) cube([2.0, 22.0, standoff_h], center=true);
        translate([ 12.7, 0, floor_h + standoff_h/2]) cube([2.0, 22.0, standoff_h], center=true);
    } else if (type == "esp32_c3_xiao") {
        // Seeed Studio XIAO (21.0 x 17.5mm)
        standoff_h = 1.8;
        translate([-8.8, 0, floor_h + standoff_h/2]) cube([1.8, 14.0, standoff_h], center=true);
        translate([ 8.8, 0, floor_h + standoff_h/2]) cube([1.8, 14.0, standoff_h], center=true);
    } else if (type == "rp2040_zero") {
        // Waveshare RP2040-Zero (18.0 x 23.5mm)
        standoff_h = 1.8;
        translate([-9.0, 0, floor_h + standoff_h/2]) cube([1.8, 16.0, standoff_h], center=true);
        translate([ 9.0, 0, floor_h + standoff_h/2]) cube([1.8, 16.0, standoff_h], center=true);
    } else if (type == "pro_micro") {
        // Pro Micro (18.0 x 33.0mm)
        standoff_h = 2.0;
        translate([-9.0, 0, floor_h + standoff_h/2]) cube([1.8, 24.0, standoff_h], center=true);
        translate([ 9.0, 0, floor_h + standoff_h/2]) cube([1.8, 24.0, standoff_h], center=true);
    }
}

module bottom_hull_box(w, l, h, r=3.0) {
    hull() {
        translate([-w/2 + r, -l/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r, -l/2 + r, 0]) cylinder(r=r, h=h);
        translate([ w/2 - r,  l/2 - r, 0]) cylinder(r=r, h=h);
        translate([-w/2 + r,  l/2 - r, 0]) cylinder(r=r, h=h);
    }
}

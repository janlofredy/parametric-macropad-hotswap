# 🎛️ Parametric Macropad & Hotswap Socket System

> ⚡ **This is 100% Vibe Made** ✨
>
> Co-engineered with AI pair programming for maker-friendly 3D printing and frictionless mechanical keyboard customization.

A modular, 3D-printable hotswap architecture designed for custom mechanical keyboards and macropads. Features precision snap-fit sockets for **Cherry MX switches** and **clickable EC11 rotary encoders**, fully organized to build **monolithic gridplates** with integrated microcontroller docks.

* **Zero Solder on Switches & Encoders**: Both MX switches and EC11 knobs remain 100% hotswappable.
* **100% Pure 3D-Printable & Screwless**: Zero screws, zero nuts, zero brass heat-set inserts. Secured by 3D-printed snap rivets and flex clips.
* **Integrated MCU Dock**: Dedicated 2.54mm pin-header dock on the gridplate with USB-C connector clearance.
* **Direct-Pin Wiring (Zero Diodes)**: Simple, clean wiring to your microcontroller for 100% True NKRO.

---

## 🔩 100% Pure 3D Printed Assembly (Zero Screws Needed)

Everything in this macropad is engineered to be **100% 3D-printable without any metal fasteners, screws, or brass inserts**:

| Component | How It Fastens Without Screws |
|---|---|
| **Case Sandwich (Top + Mid + Bottom)** | **3D-Printable Split Snap Rivets** (`cad/printable_locking_pins.scad` / `stl/printable_locking_pins_set_of_4.stl`) push through the corner holes and lock with expanding barbs underneath. |
| **Microcontroller (ESP32 / RP2040)** | **Snap-Fit Flex Clips** printed in the bottom tray deflect and snap over the PCB edges with zero screws, or **Pin Posts** that align with standard PCB mounting holes. |
| **Switch & Encoder Contacts** | **Solderless Wire-Pinch Jaws** (`cad/solderless/`) clamp switch pins against bare copper wire using 3D-printed spring-tension channels—zero commercial sockets required. |

### 🛠️ Required Bill of Materials (That's It!):
1. **Mechanical Switches** (Cherry MX compatible)
2. **Rotary Encoder** (EC11 with push-button)
3. **Microcontroller** (ESP32 DevKit, S2/S3 Mini, RP2040, etc.)
4. **Solid/Stranded Copper Wire** (22–24 AWG)
5. **Filament** (PETG or PLA)

---

## 📐 Bottom Plate Standoff Options (ESP32 & MCUs)

The bottom tray (`cad/macropad_bottom_plate.scad`) includes 3 configurable standoff styles:

1. **`snap_clips` (Recommended / 100% Screwless)**:
   - Twin cantilever spring arms printed on each side of the MCU cradle.
   - As you press your ESP32 in, the clips deflect outward and latch over the top edge of the PCB.
   - Disassembly is simple: just gently pry back the clip ears to release.
2. **`pin_posts` (100% Screwless Alignment)**:
   - 4 raised alignment pins that slide directly through the ESP32 DevKit's corner mounting holes ($\sim 2.8\text{ mm}$).
   - Locks the board against any lateral movement; the midplate holds it securely from above.
3. **`friction_rails` (Snug Press-Fit)**:
   - Precision parallel guide rails sized with a slight draft angle to grip the edges of the PCB by friction.

---

## 📂 Project Directory Structure

```
parametric-macropad-hotswap/
├── cad/                          # Parametric OpenSCAD Source Models
│   ├── macropad_top_plate.scad   # Switch & Rotary Encoder Top Plate (14mm cutouts)
│   ├── macropad_grid_plate.scad  # Master monolithic midplate with MCU dock
│   ├── macropad_bottom_plate.scad # Bottom tray with options for ESP32 & common MCUs
│   ├── macropad_complete_case.scad # Complete 3-layer sandwich assembly view
│   ├── printable_locking_pins.scad # 100% 3D-printable snap rivets & friction dowels
│   ├── keyboard_switch_socket.scad # Modular MX Kailh socket (standalone & negative)
│   ├── ec11_hotswap_socket.scad  # Modular EC11 rotary encoder socket (standalone & negative)
│   ├── hotswap_socket.scad       # All-in-one customizer model
│   └── solderless/               # 100% mechanical wire-pinch variant
│       ├── solderless_macropad_grid_plate.scad
│       ├── solderless_switch_socket.scad
│       └── solderless_ec11_socket.scad
│
├── stl/                          # 3D Printable STL Files (Ready for Slicer)
│   ├── gridplates/               # Monolithic Macropad Enclosure Plates
│   │   ├── macropad_3x3_top_plate.stl           # Top switch plate with EC11 collar
│   │   ├── macropad_3x3_with_mcu_dock.stl       # Monolithic hotswap midplate
│   │   └── macropad_3x3_bottom_plate_esp32.stl  # Bottom case tray with ESP32 dock
│   ├── printable_locking_pins_set_of_4.stl      # 4x 3D-printable snap rivets
│   ├── hotswap_sockets/          # Standard Hotswap Sockets
│   │   ├── kailh_hotswap_caddy.stl
│   │   ├── kailh_hotswap_caddy_compact.stl
│   │   ├── ec11_hotswap_socket.stl
│   │   └── ec11_hotswap_socket_compact.stl
│   └── solderless/               # 100% Solderless Wire-Pinch Sockets
│       ├── solderless_switch_socket.stl
│       ├── solderless_ec11_socket.stl
│       └── wire_spring_hotswap_socket.stl
│
├── docs/                         # Interactive 3D Inspector, Schematics & Renders
│   ├── index.html                # Interactive 3D WebGL/Canvas CAD Inspector (GitHub Pages ready)
│   ├── interactive_3d_inspector.html
│   ├── wiring_blueprint.svg      # Vector blueprint with exact dimensional clearances
│   ├── wiring_diagram.png        # Color raster wiring diagram
│   └── wiring_photo_render.jpg   # Photorealistic 3D macro render of wired socket
│
└── scripts/                      # Mesh Compilers
    ├── generate_all_sockets.py   # Pure Python binary STL generator
    └── generate_locking_pins.py  # Standalone generator for printable snap rivets
```

---

## 🕹️ Quick File Links

### 🌐 Interactive 3D CAD Inspector
* 🚀 **[Launch Live Web Inspector](https://janlofredy.github.io/parametric-macropad-hotswap/)** (or on custom domain: [janlofre.com](http://janlofre.com/parametric-macropad-hotswap/))
* 🔍 Source: [`docs/interactive_3d_inspector.html`](docs/interactive_3d_inspector.html)

### 📐 OpenSCAD Complete Enclosure
* 🔝 [`cad/macropad_top_plate.scad`](cad/macropad_top_plate.scad) — Top plate with 14mm MX cutouts & EC11 collar
* 🧱 [`cad/macropad_grid_plate.scad`](cad/macropad_grid_plate.scad) — **Master Monolithic Midplate with MCU Endpoint Dock**
* 📦 [`cad/macropad_bottom_plate.scad`](cad/macropad_bottom_plate.scad) — **Bottom Case Tray with ESP32, RP2040, Xiao & Pro Micro options**
* 🥪 [`cad/macropad_complete_case.scad`](cad/macropad_complete_case.scad) — Full 3-layer sandwich exploded assembly view
* 📌 [`cad/printable_locking_pins.scad`](cad/printable_locking_pins.scad) — 100% 3D-printable snap rivets & alignment dowels
* ⌨️ [`cad/keyboard_switch_socket.scad`](cad/keyboard_switch_socket.scad) — Modular Cherry MX hotswap socket
* 🎚️ [`cad/ec11_hotswap_socket.scad`](cad/ec11_hotswap_socket.scad) — Modular EC11 clickable rotary encoder socket

### 🖨️ Ready-to-Print 3D STL Enclosure
* 🔝 [`stl/gridplates/macropad_3x3_top_plate.stl`](stl/gridplates/macropad_3x3_top_plate.stl) — Top switch plate
* 🧱 [`stl/gridplates/macropad_3x3_with_mcu_dock.stl`](stl/gridplates/macropad_3x3_with_mcu_dock.stl) — Monolithic hotswap midplate
* 📦 [`stl/gridplates/macropad_3x3_bottom_plate_esp32.stl`](stl/gridplates/macropad_3x3_bottom_plate_esp32.stl) — Bottom tray with ESP32 cradle & USB cutout ($65.2 \times 83.2 \times 9.0\text{ mm}$)
* 📌 [`stl/printable_locking_pins_set_of_4.stl`](stl/printable_locking_pins_set_of_4.stl) — Set of 4 printable locking snap rivets

### 📊 Visual Blueprint & Renders
* 📷 [`docs/wiring_photo_render.jpg`](docs/wiring_photo_render.jpg) — Photorealistic 3D macro render
* 📐 [`docs/wiring_blueprint.svg`](docs/wiring_blueprint.svg) — Vector clearance blueprint

---

## 🖨️ Slicer Settings
* **Layer Height**: `0.16 mm` (or `0.20 mm`)
* **Perimeters / Walls**: `4 Walls` (ensures socket pin chambers are 100% solid)
* **Infill**: `40% – 50%` Gyroid / Grid
* **Material**: **PETG** (Recommended for elasticity and snap strength) or **PLA**
* **Supports**: **None (Disabled)**


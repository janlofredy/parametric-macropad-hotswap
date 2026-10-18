# 🎛️ Parametric Macropad & Hotswap Socket System

> ⚡ **This is 100% Vibe Made** ✨
>
> Co-engineered with AI pair programming for maker-friendly 3D printing and frictionless mechanical keyboard customization.

A modular, 3D-printable hotswap architecture designed for custom mechanical keyboards and macropads. Features precision snap-fit sockets for **Cherry MX switches** and **clickable EC11 rotary encoders**, fully organized to build **monolithic gridplates** with integrated microcontroller docks.

* **Zero Solder on Switches & Encoders**: Both MX switches and EC11 knobs remain 100% hotswappable.
* **Integrated MCU Dock**: Dedicated 2.54mm pin-header dock on the gridplate with USB-C connector clearance.
* **Direct-Pin Wiring (Zero Diodes)**: Simple, clean wiring to your microcontroller for 100% True NKRO.

---

## 📂 Project Directory Structure

```
parametric-macropad-hotswap/
├── cad/                          # Parametric OpenSCAD Source Models
│   ├── macropad_grid_plate.scad  # Master monolithic gridplate with MCU dock
│   ├── keyboard_switch_socket.scad # Modular MX Kailh socket (standalone & negative)
│   ├── ec11_hotswap_socket.scad  # Modular EC11 rotary encoder socket (standalone & negative)
│   ├── hotswap_socket.scad       # All-in-one customizer model
│   └── solderless/               # 100% mechanical wire-pinch variant
│       ├── solderless_macropad_grid_plate.scad
│       ├── solderless_switch_socket.scad
│       └── solderless_ec11_socket.scad
│
├── stl/                          # 3D Printable STL Files (Ready for Slicer)
│   ├── gridplates/               # Monolithic Macropad Plates
│   │   └── macropad_3x3_with_mcu_dock.stl
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
    └── generate_all_sockets.py   # Pure Python binary STL generator
```

---

## 🕹️ Quick File Links

### 🌐 Interactive 3D CAD Inspector
* 🚀 **[Launch Live Web Inspector](https://janlofredy.github.io/parametric-macropad-hotswap/)** (or on custom domain: [janlofre.com](http://janlofre.com/parametric-macropad-hotswap/))
* 🔍 Source: [`docs/interactive_3d_inspector.html`](docs/interactive_3d_inspector.html) — Full in-browser 3D WebGL/Canvas viewer with exploded views, cross-sections, and real-time switch/encoder inspection.

### 📐 OpenSCAD CAD Models
* 🧱 [`cad/macropad_grid_plate.scad`](cad/macropad_grid_plate.scad) — **Master Monolithic Gridplate with MCU Endpoint Dock**
* ⌨️ [`cad/keyboard_switch_socket.scad`](cad/keyboard_switch_socket.scad) — Modular Cherry MX hotswap socket
* 🎚️ [`cad/ec11_hotswap_socket.scad`](cad/ec11_hotswap_socket.scad) — Modular EC11 clickable rotary encoder socket
* 🌿 [`cad/solderless/solderless_macropad_grid_plate.scad`](cad/solderless/solderless_macropad_grid_plate.scad) — 100% Solderless wire-pinch monolithic gridplate

### 🖨️ Ready-to-Print 3D STL Models
* 🚀 [`stl/gridplates/macropad_3x3_with_mcu_dock.stl`](stl/gridplates/macropad_3x3_with_mcu_dock.stl) — Complete 3x3 macropad plate with top MCU dock ($65.2 \times 83.2 \times 5.2\text{ mm}$)
* 🔌 [`stl/hotswap_sockets/kailh_hotswap_caddy.stl`](stl/hotswap_sockets/kailh_hotswap_caddy.stl) — MX switch socket with M2 tabs
* 🔌 [`stl/hotswap_sockets/ec11_hotswap_socket.stl`](stl/hotswap_sockets/ec11_hotswap_socket.stl) — EC11 encoder socket with M2 tabs

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

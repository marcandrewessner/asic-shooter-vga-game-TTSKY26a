![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# MAW Bird Shooter VGA Game

A fully synthesized single-player arcade game fabricated as a Tiny Tapeout ASIC. Move a crosshair with four directional buttons and press SHOOT to hit a wandering animated bird within 10 shots. Hit 7 or more to win.

- [Read the full documentation](docs/info.md)

## How it works

The chip drives a 640×480 60 Hz VGA display from a 50 MHz clock. An animated bird wanders across the screen driven by a triangle-wave path seeded by two 16-bit LFSRs. The player steers a crosshair with directional buttons and fires with the SHOOT button. Each shot is scored as a HIT or MISS based on whether the crosshair overlaps the bird bounding box. After 10 shots a win or lose screen is shown; press SHOOT to restart.

Internally the design is split into:
- A game-state FSM (start screen → shooting → hit/miss delay → won/lost)
- A crosshair controller that moves one step per 30 Hz game tick while a button is held
- An enemy-movement module animating the bird along randomised paths
- A five-frame animated bird sprite
- A render engine that composites all sprites and overlays onto the VGA signal

All button inputs are CDC-synchronised and edge-detected. The 60 Hz VGA frame rate is divided by two to produce a 30 Hz game tick so gameplay speed is consistent regardless of display timing.

## Pinout

| Pin | Direction | Signal | Notes |
|-----|-----------|--------|-------|
| ui[7] | Input | BTN_UP | Active-high. Requires external 10 kΩ pull-down to GND. |
| ui[6] | Input | BTN_DOWN | Active-high. Requires external 10 kΩ pull-down to GND. |
| ui[5] | Input | BTN_LEFT | Active-high. Requires external 10 kΩ pull-down to GND. |
| ui[4] | Input | BTN_RIGHT | Active-high. Requires external 10 kΩ pull-down to GND. |
| ui[3] | Input | BTN_SHOOT | Active-high. Requires external 10 kΩ pull-down to GND. |
| ui[2:0] | — | unused | |
| uo[7] | Output | VGA_HSYNC | |
| uo[6] | Output | VGA_VSYNC | |
| uo[5] | Output | VGA_R | 1-bit red |
| uo[4] | Output | VGA_G | 1-bit green |
| uo[3] | Output | VGA_B | 1-bit blue |
| uo[2:0] | — | unused (tied low) | |
| uio[7:0] | — | unused (driven low) | Configured as outputs |

## External hardware

- VGA monitor or TinyVGA PMOD (standard Tiny Tapeout VGA PMOD pinout on uo[7:0])
- 5× momentary push-buttons
- 5× 10 kΩ pull-down resistors (one per button pin, to GND)

> **Button wiring:** All buttons are active-high. Use pull-**down** resistors so the pins idle at logic 0 and go to logic 1 when pressed. Pull-up resistors will invert the polarity and the game will not respond correctly.

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that makes it easier and cheaper than ever to get your digital designs manufactured on a real chip. To learn more, visit https://tinytapeout.com.

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)

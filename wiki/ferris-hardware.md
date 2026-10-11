---
summary: The Ferris family as defined in QMK — 0_1, 0_2 variants and the Sweep — and what the ferris/sweep target this repo builds resolves to (Pro Micro, ATmega32u4, Caterina, serial split).
sources:
  - .agent-workspace/.repos/qmk_firmware/keyboards/ferris/sweep/keyboard.json
  - .agent-workspace/.repos/qmk_firmware/keyboards/ferris/sweep/readme.md
  - .agent-workspace/.repos/qmk_firmware/keyboards/ferris/0_1/matrix.c
  - .agent-workspace/.repos/qmk_firmware/keyboards/ferris/0_2/rules.mk
  - .agent-workspace/.repos/qmk_firmware/data/mappings/defaults.hjson
tags:
  - qmk
  - ferris
  - hardware
---

# Ferris hardware in QMK

Part of [[qmk-firmware]]. The keymap built for it is [[ferris-keymap]].

## Variants

`keyboards/ferris/` holds three distinct machines:

- `0_1` — ATmega32u4, `atmel-dfu` bootloader, LTO on.
- `0_2/{base,bling,compact,high,mini}` — STM32F072, `stm32-dfu`.
- `sweep` — the Ferris Sweep, built on two Pro Micros.

`0_1` and `0_2` are not "split_common" keyboards: one MCU reads the other half
through an MCP23017 I2C expander[^matrix01][^rules02]. So split options such as
`SPLIT_USB_DETECT` only matter on the Sweep.

## The target this repo builds: `ferris/sweep`

The repo's built artefact is named `ferris_sweep_bdura.hex`, and
`qmk compile -kb ferris/sweep -km bdura` builds at 94% of available flash
([[qmk-build-pipeline]]). So the target is the Sweep. This assumes Pro Micro (AVR)
controllers. An RP2040 Pro Micro clone would need a converter and would produce
a `.uf2` instead.

What `keyboard.json` declares[^sweep]:

- **Controller:** `development_board: promicro`, which expands to `atmega32u4` +
  `caterina` bootloader[^defaults]. Caterina reserves 4 KB, so usable flash is
  28672 bytes.
- **Features:** bootmagic, extrakey, **mousekey**, unicode. `MOUSEKEY_ENABLE`
  is therefore on even though the keymap's `rules.mk` doesn't set it (see
  [[keymap-config]]).
- **Matrix:** direct pins, 4 rows × 5 columns per half, with a separate mirrored
  pin list for the right half. The thumb keys are row 3 (left) and row 7 (right),
  columns 0–1 ([[thumb-cluster]]).
- **Split:** enabled, serial transport on pin D2. No `handedness` setting (see
  [[split-handedness]]).
- **Layout:** `LAYOUT_split_3x5_2` (34 keys), aliased to `LAYOUT`. Community
  layout `split_3x5_2`.

## Bootloader entry

From the Sweep readme[^readme], any of:

- bootmagic: hold the top outer key while plugging in that half;
- the reset button;
- a `QK_BOOT` key.

The readme also gives an `#undef DIRECT_PINS` recipe for PCB variants with swapped
pins. Flashing is covered in [[qmk-flashing]].

## Converters

`CONVERT_TO=<target>` retargets a Pro Micro board to a pin-compatible ARM
controller, e.g. `rp2040_ce`, `kb2040`, `elite_pi`, `proton_c`. Use it as
`qmk compile -e CONVERT_TO=rp2040_ce …`.

[^sweep]: [keyboards/ferris/sweep/keyboard.json](../.repos/qmk_firmware/keyboards/ferris/sweep/keyboard.json)
[^defaults]: [data/mappings/defaults.hjson](../.repos/qmk_firmware/data/mappings/defaults.hjson),
             l.68–72
[^readme]: [keyboards/ferris/sweep/readme.md](../.repos/qmk_firmware/keyboards/ferris/sweep/readme.md)
[^matrix01]: [keyboards/ferris/0_1/matrix.c](../.repos/qmk_firmware/keyboards/ferris/0_1/matrix.c),
             l.31–47
[^rules02]: [keyboards/ferris/0_2/rules.mk](../.repos/qmk_firmware/keyboards/ferris/0_2/rules.mk)

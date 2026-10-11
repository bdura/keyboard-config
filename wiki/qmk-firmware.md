---
summary: Exploration of QMK Firmware
url: https://github.com/qmk/qmk_firmware
commit-hash: bd500ae0929bc708410a55e7795fedd451675eb4
---

# QMK Firmware

QMK is a keyboard firmware for AVR and ARM/RISC-V microcontrollers, descended from
Hasu's tmk_keyboard[^readme]. A keyboard is described by data (`keyboard.json`)
plus optional C. A keymap is a small C or JSON file layered on top. A single make +
Python build turns any `keyboard:keymap` pair into a flashable `.hex`, `.bin`
or `.uf2`. Features such as combos, Caps Word and tap-hold options are opt-in,
and only enabled ones are compiled in.

This repo builds against QMK as an external userspace ([[qmk-userspace]]).
The pages below describe QMK at the commit checked out in `.firmware/`
(`master`, `bd500ae092`, 2026-03-19; newest tag `0.32.5`). The study clone in
`.agent-workspace/.repos/qmk_firmware` is pinned to the same commit.

## Top-level layout

- `quantum/` — QMK's own layer: keycode processing (`process_keycode/`), tap-hold,
  combos, Caps Word, `split_common/`, keymap introspection.
- `tmk_core/` — the inherited TMK base, mainly USB stacks (LUFA, ChibiOS, V-USB).
- `platforms/{avr,chibios,test}/` — per-MCU-family build, bootloader and flash
  rules, plus Pro Micro converters.
- `drivers/` — peripheral drivers (I2C, LED, OLED…).
- `keyboards/` — one folder per board, nested at most 5 levels deep.
  That depth is hard-coded in the make system[^constants].
- `builddefs/` — the make machinery (`build_keyboard.mk`, `locate_keymap.mk`,
  `common_features.mk`, `generic_features.mk`, `common_rules.mk`).
- `lib/python/qmk/` — the Python library and CLI subcommands, loaded by the
  separately installed `qmk` CLI. Other `lib/*` folders are git submodules (ChibiOS,
  LUFA, V-USB, pico-sdk…)[^gitmodules].
- `data/` — JSON schemas, data-driven mappings, keycode constants.

## Feature and design pages

How the build works:

- [[qmk-external-userspace]] — how QMK finds and overlays a userspace,
  the `build_targets` manifest, keymap precedence.
- [[qmk-build-pipeline]] — the two-stage make, config layering order, data-driven
  config, keymap introspection, build outputs.
- [[qmk-firmware-checkout]] — `qmk setup`, `qmk_home`, submodules, the
  `master`/`develop` release cycle.

Hardware and flashing:

- [[ferris-hardware]] — the Ferris family in QMK and what `ferris/sweep` resolves
  to.
- [[split-handedness]] — how a split board decides left/right and which half is
  master.
- [[qmk-flashing]] — `qmk flash`, the Caterina flow, per-half targets.

Features used by the keymap:

- [[qmk-tap-hold]] — tap-hold options available at this commit (Flow Tap,
  Chordal Hold, Speculative Hold…).
- [[qmk-combos]] — how combos match keycodes.
- [[qmk-caps-word]] — Caps Word behaviour and activation options.

[^readme]: [readme.md](../.repos/qmk_firmware/readme.md)
[^constants]: [lib/python/qmk/constants.py](../.repos/qmk_firmware/lib/python/qmk/constants.py),
              `MAX_KEYBOARD_SUBFOLDERS = 5`
[^gitmodules]: [.gitmodules](../.repos/qmk_firmware/.gitmodules)

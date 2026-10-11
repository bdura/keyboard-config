---
summary: RMK split keyboards — a central that runs the whole keymap and peripherals that only stream key events; roles are fixed by which binary you flash, over serial or BLE.
sources:
  - .agent-workspace/.repos/rmk/rmk/src/split/mod.rs
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/features/split_keyboard.mdx
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/configuration/split_keyboard.md
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/configuration/keyboard_matrix.md
  - .agent-workspace/.repos/rmk/examples/use_config/rp2040_split_pio/keyboard.toml
tags:
  - rmk
  - split
---

# RMK split keyboards

Part of [[rmk-firmware]]. Compare with QMK's runtime master and handedness
detection in [[split-handedness]].

## Decision: the central does everything

A split keyboard has one central and N peripherals.

- Peripherals send key and pointing events to the central.
- The central sends back layer, LED, connection, WPM and sleep state[^msg].
- All keymap and behaviour processing happens on the central (inferred from the
  message set).

Each part declares `rows`, `cols`, `row_offset` and `col_offset` within one
unified matrix, and overlaps are rejected[^conf].

## Roles are fixed at build time

Central and peripheral are **separate binaries**, and the host talks only to the
central[^feat]. The code has no USB-detect role election and no handedness pin
or EEPROM logic[^msg]. In QMK terms:

- A wired split must have USB plugged into the half flashed as central.
  This is like `MASTER_LEFT` with no `EE_HANDS` option.
- "Handedness" is simply which binary you flashed on which half.
- The `L`/`R` hand markers in `[layout].map` are only used by `unilateral_tap`
  ([[rmk-tap-hold]]). They play no part in split roles.

## Transports

- **Serial:** any `embedded-io-async` Read/Write.
  - On RP2040, PIO gives a half-duplex link over a single wire:
    set `instance = "PIO0"` with `tx_pin == rx_pin`. This fits the Sweep's single
    TRS signal line[^conf][^pio].
  - From `keyboard.toml`, serial split is generated for RP2040 only[^conf].
- **BLE:** on nRF52/54, ESP32 and Pico W. This is the only TOML option for a
  nice!nano split.

## Flashing

Each half is flashed separately with its own binary ([[rmk-build-and-flash]]).
`bootmagic = [row, col]` is set per half, and the docs warn never to hot-plug the
TRRS cable[^matrix]. The experimental `dfu_split` feature can forward firmware
to peripherals over a wired link.

[^msg]: [rmk/src/split/mod.rs](../.repos/rmk/rmk/src/split/mod.rs), l.41–70
[^conf]: [docs/configuration/split_keyboard.md](../.repos/rmk/docs/docs/main/docs/configuration/split_keyboard.md),
         l.63–135
[^feat]: [docs/features/split_keyboard.mdx](../.repos/rmk/docs/docs/main/docs/features/split_keyboard.mdx),
         l.3, l.32, l.53–90
[^pio]: [examples/use_config/rp2040_split_pio/keyboard.toml](../.repos/rmk/examples/use_config/rp2040_split_pio/keyboard.toml)
[^matrix]: [docs/configuration/keyboard_matrix.md](../.repos/rmk/docs/docs/main/docs/configuration/keyboard_matrix.md),
           l.97–137

---
summary: How qmk flash works — a make goal dispatched on the bootloader; Caterina is flashed by watching for a new serial port; per-half split targets.
sources:
  - .agent-workspace/.repos/qmk_firmware/lib/python/qmk/cli/flash.py
  - .agent-workspace/.repos/qmk_firmware/platforms/avr/flash.mk
tags:
  - qmk
  - flashing
---

# Flashing with QMK

Part of [[qmk-firmware]].

## Mechanism

`qmk flash -kb <kb> -km <km> [-bl <goal>]` compiles with make goal `<goal>`,
which defaults to `flash`[^flashpy]. `flash` then picks a method based on
`BOOTLOADER`[^flashmk]. `qmk flash <file>` flashes a prebuilt `.hex`/`.bin`/`.uf2`
without compiling.

For **Caterina** (Pro Micro, used by `ferris/sweep`, see [[ferris-hardware]]),
`EXEC_AVRDUDE`[^flashmk]:

1. snapshots `/dev/tty*`;
2. loops until a new tty appears; you reset the board meanwhile;
3. waits for the new port to become writable;
4. runs `avrdude -p atmega32u4 -c avr109 -P <tty> -U flash:w:<hex>`.

After a reset, Caterina shows up as a serial port for only a few seconds,
under an unpredictable name. Comparing the tty list before and after is a portable
way to catch it (inferred).

The Nix dev shell's `qmk` package includes `avrdude`, `dfu-util` and the other
flashers ([[nix-dev-shell]]).

## Split boards

Both halves get the same firmware, but each is flashed separately over its own
USB port. Per-half goals are listed by `qmk flash --bootloaders`[^flashpy]:

- `avrdude-split-left` / `avrdude-split-right`;
- `dfu-split-*`, `dfu-util-split-*`, `uf2-split-*`.

The per-half goals also write `eeprom-lefthand.eep` / `eeprom-righthand.eep`.
That handedness flag only matters with `EE_HANDS` ([[split-handedness]])[^flashmk].

## For this repo

```shell
qmk flash -kb ferris/sweep -km bdura   # then reset the plugged half
```

Repeat for the other half. To enter the bootloader, see [[ferris-hardware]].
Not yet tried from this repo; current blockers are listed in [[repo-lifecycle]].

[^flashpy]: [lib/python/qmk/cli/flash.py](../.repos/qmk_firmware/lib/python/qmk/cli/flash.py)
[^flashmk]: [platforms/avr/flash.mk](../.repos/qmk_firmware/platforms/avr/flash.mk),
            l.78–130, l.171–189

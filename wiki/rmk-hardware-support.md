---
summary: MCUs RMK supports (nRF52/54, RP2040/2350, STM32, ESP32…) — no AVR, so the Pro Micro Sweep cannot run it; a nice!nano (BLE split) or an RP2040 Pro Micro clone (wired split) would be needed.
sources:
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/getting_started/supported_hardwares.md
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/configuration/keyboard_device.mdx
  - .agent-workspace/.repos/rmk/rmk-config/src/default_config/nice_nano_v2.toml
  - .agent-workspace/.repos/rmk/rust-toolchain.toml
tags:
  - rmk
  - hardware
---

# RMK hardware support

Part of [[rmk-firmware]]. Relates to [[ferris-hardware]].

## Supported MCUs

RMK supports nRF52/54, RP2040/2350, STM32, ESP32 and SF32LB52[^hw][^chips].
Adding a chip needs an Embassy HAL with `embassy-usb-driver` traits, plus `bt-hci`
traits for BLE[^hw].

**AVR is not supported.** Neither the hardware table nor the chip list mentions it,
and the toolchain targets are only `thumbv6m/7m/7em/8m` and `riscv32`[^toolchain].
**The current Sweep, with two ATmega32u4 Pro Micros, cannot run RMK:
both controllers would have to be replaced.**

## Pro Micro-footprint candidates for a Sweep

- **nice!nano v2 (nRF52840).**
  - It is a first-class board: `board = "nice!nano_v2"` sets up USB, BLE,
    the battery and storage[^nn].
  - `nrfmicro`, `bluemicro840` and `XIAO BLE` are also listed.
  - From `keyboard.toml`, the split link can only be BLE ([[rmk-split]]),
    so this means a wireless split with a battery in each half.
- **RP2040 Pro Micro clones** (Elite-Pi, KB2040…) with `chip = "rp2040"`.
  - The wired split works over the Sweep's single TRS wire, using PIO half-duplex.
  - Firmware is flashed as UF2 through BOOTSEL.

## No pin aliasing

RMK has no equivalent of QMK's `CONVERT_TO` (inferred from absence). Pins use raw
MCU names (`P0_xx`, `PIN_x`)[^matrix]. The Sweep's direct-pin wiring would have
to be translated by hand from Pro Micro labels to GPIO numbers, for each half.
It then maps to `matrix_type = "direct_pin"` under `[split.central.matrix]`
and `[split.peripheral.matrix]`[^dp].

[^hw]: [docs/getting_started/supported_hardwares.md](../.repos/rmk/docs/docs/main/docs/getting_started/supported_hardwares.md),
       l.25–32
[^chips]: [docs/configuration/keyboard_device.mdx](../.repos/rmk/docs/docs/main/docs/configuration/keyboard_device.mdx),
          l.98–115
[^toolchain]: [rust-toolchain.toml](../.repos/rmk/rust-toolchain.toml);
              [flake.nix](../.repos/rmk/flake.nix), l.25–34
[^nn]: [rmk-config/src/default_config/nice_nano_v2.toml](../.repos/rmk/rmk-config/src/default_config/nice_nano_v2.toml)
[^matrix]: [docs/configuration/keyboard_matrix.md](../.repos/rmk/docs/docs/main/docs/configuration/keyboard_matrix.md),
           l.42–51
[^dp]: [examples/use_config/nrf52840_ble_split_direct_pin/keyboard.toml](../.repos/rmk/examples/use_config/nrf52840_ble_split_direct_pin/keyboard.toml)

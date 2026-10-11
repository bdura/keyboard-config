---
summary: An RMK keyboard is its own Cargo project depending on the rmk crate — built with cargo and cargo-make into uf2, flashed by drag-and-drop or probe-rs, or built in the cloud from keyboard.toml alone.
sources:
  - .agent-workspace/.repos/rmk/README.md
  - .agent-workspace/.repos/rmk/.github/workflows/user_build.yml
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/user_guide/create_firmware/local_compilation.mdx
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/user_guide/create_firmware/cloud_compilation.mdx
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/user_guide/flash_firmware/index.mdx
  - .agent-workspace/.repos/rmk/examples/use_config/rp2040_split
  - .agent-workspace/.repos/rmk/flake.nix
tags:
  - rmk
  - build
  - flashing
---

# RMK project model, build and flash

Part of [[rmk-firmware]]. Counterpart of [[qmk-external-userspace]],
[[qmk-build-pipeline]] and [[qmk-flashing]].

## Decision: every keyboard is an external project

RMK is a crate dependency: `rmk = { version = "0.9", features = [...] }`.
`rmkit init` generates a project from `rmk-template`[^readme][^local].
So every RMK keyboard is "external" by construction. There is no monorepo of
keyboards to fork, and no need for something like QMK's `qmk.json` overlay.

**Cloud builds:** the reusable workflow `.github/workflows/user_build.yml` takes
only `keyboard.toml` and `vial.json`, plus `rmk_version` (default `main`).
It runs `rmkit create`, builds, and uploads uf2, hex and elf files. A split build
yields `<name>-central` and `<name>-peripheral`. Cargo features cannot be changed
in the cloud template[^cloud].

**Limits:** you track RMK versions through Cargo. Minor versions do break things:
`docs/migration/` has guides from v0.6 up to v0.10.

## Build

1. `cargo build --release` produces an ELF without extension in
   `target/<triple>/release/`.
2. `cargo make uf2 --release` runs objcopy, then `cargo hex-to-uf2 --family …`
   ([`Makefile.toml`](../.repos/rmk/examples/use_config/rp2040_split/Makefile.toml)).

The release profile is `opt-level = "z"`, `lto = "fat"`, `codegen-units = 1`.

## Flash

- Drag and drop the uf2 onto the bootloader drive: RP2040 BOOTSEL, or the
  Adafruit nRF52 bootloader on a nice!nano. With the Adafruit bootloader,
  `memory.x` FLASH must start at `0x1000`[^flash].
- `cargo run --release` with a probe-rs runner, which needs a debug probe.
- `elf2uf2-rs -d` as the runner on RP2040; `espflash` for ESP32.
- The `Bootloader` keycode needs the `rp2040`, `adafruit_bl` or `zsa_voyager_bl`
  feature. `bootmagic` is the alternative.

## Nix

RMK's `flake.nix` is a **dev shell only**: fenix stable and nightly toolchains,
embedded targets, probe-rs, flip-link, cargo-make, espflash, and the
`RUST_MIN_STACK`/`LIBCLANG_PATH` variables[^flake]. It is the analogue of
[[nix-dev-shell]]. It has no equivalent of [[nix-firmware-package]]: a reproducible
RMK firmware would need a new derivation that vendors the crates.io dependencies,
e.g. with crane or naersk (not verified).

[^readme]: [README.md](../.repos/rmk/README.md), l.52–116
[^local]: [docs/user_guide/create_firmware/local_compilation.mdx](../.repos/rmk/docs/docs/main/docs/user_guide/create_firmware/local_compilation.mdx),
          l.45–175
[^cloud]: [docs/user_guide/create_firmware/cloud_compilation.mdx](../.repos/rmk/docs/docs/main/docs/user_guide/create_firmware/cloud_compilation.mdx),
          l.5–9
[^flash]: [docs/user_guide/flash_firmware/index.mdx](../.repos/rmk/docs/docs/main/docs/user_guide/flash_firmware/index.mdx),
          l.11–24
[^flake]: [flake.nix](../.repos/rmk/flake.nix), l.25–187

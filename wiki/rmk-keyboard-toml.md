---
summary: RMK's keyboard.toml is expanded into Rust by proc-macros at compile time, with Override hooks and a full Rust API as escape hatches; some settings exist only in Rust.
sources:
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/features/configuration.md
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/features/use_rust_api.md
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/configuration/behavior.md
  - .agent-workspace/.repos/rmk/rmk-macro/src/codegen/override_helper.rs
  - .agent-workspace/.repos/rmk/examples/use_config/rp2040_split
tags:
  - rmk
  - configuration
---

# RMK keyboard.toml and code generation

Part of [[rmk-firmware]]. It plays the role of QMK's data-driven `keyboard.json` +
`keymap.c` ([[qmk-build-pipeline]]), but the whole keyboard (matrix, keymap,
behaviours, split) lives in one TOML file.

## How it works

Config is loaded in three layers, the later ones winning: `event_default.toml` →
chip or board defaults → the user's `keyboard.toml`.

The file is parsed twice[^conf]:

- by `rmk-types/build.rs`, which turns `[rmk]` and `[event]` into `const`s;
- by `rmk-macro`, when the macros expand.

A user's `main.rs` can be as short as `#[rmk_keyboard] mod keyboard {}`.
A split keyboard is two `[[bin]]`s, one with `#[rmk_central]` and one with
`#[rmk_peripheral(id = 0)]`[^example].

Keymaps are written as strings of actions per layer, with QMK-like names:
`MT(A, LGui)`, `LT(1, Space)`, `DF(1)`. `[aliases]` can name long actions.
Keymap strings take no inline comments[^layout].

## Escape hatches

- `#[Override(chip_config | chip_init | usb | entry | bind_interrupt)]` functions
  replace pieces of the generated code[^override].
- `#[register_processor]` adds custom tasks ([[rmk-async-runtime]]).
- The full Rust API builds `KeymapData`, `BehaviorConfig`, `Matrix` and `Keyboard`
  yourself, with `layer!`/`k!`/`mo!` macros for the keymap[^rust].

## Why

The docs promise configuration "requiring no Rust programming knowledge"[^conf].
A TOML-only project also makes the cloud builds in [[rmk-build-and-flash]] possible.

## Limits

- **Some settings are Rust-only:** `BehaviorConfig.default_layer`, `tap`,
  and mouse-key acceleration. TOML only exposes the mouse intervals[^behavior].
- **Some matrices are Rust-only:** the bidirectional and 74HC595 types.
- **Wired serial split is RP2040-only** from TOML ([[rmk-split]]).
- **No conditional logic:** anything like QMK's `process_record_user` needs a
  Rust processor.

[^conf]: [docs/features/configuration.md](../.repos/rmk/docs/docs/main/docs/features/configuration.md),
         l.3, l.40; [CLAUDE.md](../.repos/rmk/CLAUDE.md)
[^example]: [examples/use_config/rp2040_split/Cargo.toml](../.repos/rmk/examples/use_config/rp2040_split/Cargo.toml),
            l.45–52
[^layout]: [docs/configuration/layout.md](../.repos/rmk/docs/docs/main/docs/configuration/layout.md),
           l.49, l.300–317
[^override]: [rmk-macro/src/codegen/override_helper.rs](../.repos/rmk/rmk-macro/src/codegen/override_helper.rs),
             l.5–16
[^rust]: [docs/features/use_rust_api.md](../.repos/rmk/docs/docs/main/docs/features/use_rust_api.md)
[^behavior]: [docs/configuration/behavior.md](../.repos/rmk/docs/docs/main/docs/configuration/behavior.md),
             l.12–14

---
summary: Exploration of RMK
url: https://github.com/rmk-rs/rmk
commit-hash: 6e84c364eaa2d400d58cbcaaa441415b7340fe14
---

# RMK

RMK is a `no_std` Rust keyboard firmware **library** built on Embassy, Rust's
async embedded runtime[^intro]. It targets ARM Cortex-M, RISC-V and Xtensa MCUs:
nRF52/54, RP2040/2350, STM32, ESP32 and SF32LB52. It handles USB and BLE keyboards,
split keyboards over serial or BLE, and runtime remapping through Vial (or its own
experimental "Rynk" protocol). You configure a keyboard either with a declarative
`keyboard.toml` or directly with the Rust API.

The pages below describe `main` at `6e84c364` (2026-10-11), the commit
the study clone in `.agent-workspace/.repos/rmk` is pinned to. This repo
does not use RMK: it was explored as an alternative to [[qmk-firmware]].
See [[rmk-porting-assessment]] for what moving the bdura keymap would take,
and [[firmware-comparison]] for a side-by-side with QMK.

## Identity

- **License:** MIT OR Apache-2.0[^cargo].
- **Maturity:** pre-1.0.
  - Crate versions: `rmk` 0.9.0 (released 2026-08-27), `rmk-macro` 0.8.0,
    `rmk-types` 0.4.0[^cargo].
  - `main` already carries breaking unreleased changes[^changelog].
  - The roadmap still lists RGB, NKRO, deep sleep and OTA as missing[^roadmap].
  - The project has one main author.
- **Positioning:** the docs never compare RMK to QMK or ZMK directly, but they
  borrow from both:
  - QMK: layer semantics "match QMK's definitions"[^layout]; a script converts
    QMK/Vial keycodes (`scripts/via2rmk.py`).
  - ZMK: one-shot release modes and `require-prior-idle-ms`[^behavior];
    a FAQ entry on going back to ZMK[^faq].
  - In practice it aims at ZMK's wireless, low-power niche, with QMK's keymap
    vocabulary and Vial compatibility (inferred).

## Repository layout

There is no root `Cargo.toml`: each crate and each example builds on its own.

- `rmk/` — the core.
  - `src/keyboard.rs` holds the key-processing state machine.
  - Other modules: `matrix/`, `split/`, `ble/`, `usb/`, `host/{via,rynk}`,
    `storage`, `event/`.
  - Behaviour tests are written as TOML scenarios in `tests/scenarios/`.
- `rmk-config/` — parses `keyboard.toml`, with per-chip and per-board defaults
  in `src/default_config/`.
- `rmk-macro/` — the proc-macros: `#[rmk_keyboard]`, `#[rmk_central]`,
  `#[rmk_peripheral]`, `#[processor]`, `#[Override(...)]`…
- `rmk-types/` — shared types (`KeyAction`, keycodes, combo, morse, fork).
- `rynk/` — the native host protocol.
- `examples/use_config/*` (TOML-driven) and `examples/use_rust/*` (pure Rust):
  about 30 boards.
- `docs/` — the versioned documentation site.
- `flake.nix` — a Nix **dev shell only**; there is no firmware derivation.

## Feature and design pages

Architecture:

- [[rmk-async-runtime]] — Embassy async, every component joined into one future,
  and a pub/sub event bus.
- [[rmk-keyboard-toml]] — `keyboard.toml` expanded by proc-macros, and the Rust
  escape hatches.
- [[rmk-keymap-storage]] — keymap persisted in flash, where the stored copy beats
  a reflash; Vial.
- [[rmk-split]] — central/peripheral roles fixed at build time; serial and BLE
  transports.
- [[rmk-build-and-flash]] — your keyboard is your own Cargo project; cargo, uf2,
  probe-rs, cloud builds.
- [[rmk-hardware-support]] — supported MCUs, no AVR, and what a Ferris Sweep
  would need.

Features used by the bdura keymap:

- [[rmk-tap-hold]] — one "morse" engine for tap-hold, tap dance and home-row mods.
- [[rmk-combos]] — combos match whole key actions and are processed before tap-hold.
- [[rmk-caps-word]] — built-in, with fixed rules and a fixed 5 s timeout.

Other features, not studied in depth:

- Layers: `MO`, `LT`, `LM`, `TG`, `TO`, `TT`, `OSL`, `DF`, `PDF`, tri-layer[^layout].
- One-shot mods and layers, forks (output that depends on modifier state), macros,
  `Repeat`.
- Mouse keys: only the intervals can be set in TOML; acceleration needs Rust.
- BLE profiles, battery, sleep, dongle mode, displays, encoders, pointing devices.
- **No RGB:** `Rgb*` keycodes parse but do nothing, and the code logs "Light
  control is not supported"[^keycodes].

## Contradictions in the material

- The `main` docs describe unreleased post-0.9 APIs (an "upgrade from v0.9 to
  v0.10" guide), yet their Cargo snippets still say `rmk = "0.9"`. Someone using
  crates.io 0.9.0 may see different APIs.
- The configuration index advertises "RGB lighting"[^confindex], but RMK has no RGB:
  the `[light]` section only drives lock-LED pins.

[^intro]: [docs/getting_started/introduction.mdx](../.repos/rmk/docs/docs/main/docs/getting_started/introduction.mdx);
          [README.md](../.repos/rmk/README.md)
[^cargo]: [rmk/Cargo.toml](../.repos/rmk/rmk/Cargo.toml), l.3–15
[^changelog]: [rmk/CHANGELOG.md](../.repos/rmk/rmk/CHANGELOG.md), l.3–50
[^roadmap]: [docs/development/roadmap.md](../.repos/rmk/docs/docs/main/docs/development/roadmap.md)
[^layout]: [docs/configuration/layout.md](../.repos/rmk/docs/docs/main/docs/configuration/layout.md),
           l.271–283
[^behavior]: [docs/configuration/behavior.md](../.repos/rmk/docs/docs/main/docs/configuration/behavior.md),
             l.47–48, l.79
[^faq]: [docs/getting_started/faq.md](../.repos/rmk/docs/docs/main/docs/getting_started/faq.md),
        l.188–219
[^keycodes]: [docs/configuration/keymap_configuration/keycodes.md](../.repos/rmk/docs/docs/main/docs/configuration/keymap_configuration/keycodes.md),
             l.302–307; [rmk/src/keyboard.rs](../.repos/rmk/rmk/src/keyboard.rs),
             l.1325
[^confindex]: [docs/configuration/index.mdx](../.repos/rmk/docs/docs/main/docs/configuration/index.mdx),
              l.20

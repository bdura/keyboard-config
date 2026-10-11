---
summary: QMK versus RMK for this keymap, assuming compatible boards — ease of use, features and Nix compatibility; a synthesis of the QMK and RMK pages, nothing built or tested.
sources:
  - .agent-workspace/wiki/rmk-porting-assessment.md
  - .agent-workspace/wiki/repo-lifecycle.md
  - .agent-workspace/wiki/nix-firmware-package.md
tags:
  - comparison
  - qmk
  - rmk
---

# QMK versus RMK

This page compares [[qmk-firmware]] and [[rmk-firmware]] for the bdura keymap.
It assumes boards that RMK supports, such as nice!nano v2 or RP2040 Pro Micro clones
([[rmk-hardware-support]]). It summarises other wiki pages, which carry the sources.
Nothing here was built or tested; the RMK side comes from reading its code and docs.

## Summary

Every feature the keymap uses carries over to RMK, except RGB, which is
inactive in [[keymap-config]] anyway. RMK brings wireless support and Vial.
In exchange it gives up git as the single source of truth for the keymap,
and the reproducible Nix firmware package.

## Ease of use

- **Configuration.**
  - QMK: C files (`keymap.c`, `config.h`, `rules.mk`) in an external userspace
    ([[qmk-userspace]]).
  - RMK: one declarative `keyboard.toml` with QMK-like action names
    ([[rmk-keyboard-toml]]). Conditional logic needs Rust, and a few settings are
    Rust-only.
- **Build and flash.**
  - QMK: `make` to iterate, `nix build` for the artefact, `nix run .` to flash.
    The same firmware goes on both halves ([[repo-lifecycle]]).
  - RMK: a Cargo project built with `cargo build` then `cargo make uf2`, flashed
    by drag-and-drop or probe-rs. The two halves get two different binaries,
    and the USB half must be the one flashed as central ([[rmk-build-and-flash]],
    [[rmk-split]]).
- **Source of truth.** The keymap stored in flash beats a reflash, so a keymap
  change needs a `clear_layout` flash or Vial turned off. `vial.json` must also
  be kept in sync by hand ([[rmk-keymap-storage]]). This is the largest workflow
  difference.
- **Maturity and toolchain.**
  - RMK is pre-1.0, has one main author, and minor versions break things.
  - Its toolchain is heavier: Rust, embedded targets, flip-link, cargo-make,
    probe-rs.
  - Pins use raw GPIO names, with no `CONVERT_TO` equivalent ([[rmk-firmware]],
    [[rmk-async-runtime]]).

## Features

| | QMK | RMK |
|---|---|---|
| Home-row mods | [[qmk-tap-hold]]: Flow Tap, Chordal Hold, Speculative Hold | [[rmk-tap-hold]]: the current settings port directly. Flow tap uses one global idle time. `unilateral_tap` is experimental. No Speculative Hold |
| Combos | [[qmk-combos]] | [[rmk-combos]]: same keycode matching, plus a per-combo `layer` |
| Caps Word | [[qmk-caps-word]]: configurable timeout, hook, both-Shifts activation | [[rmk-caps-word]]: fixed rules and a fixed 5 s timeout |
| Layers and thumbs | `MEH_T` available | Everything maps; Meh must be spelled `MT(Space, LCtrl \| LShift \| LAlt)` |
| RGB | Supported | None |
| Wireless | Not covered in this wiki | BLE split, battery, sleep, multiple profiles, dongle mode |
| Runtime remap | Not covered in this wiki | Vial, on by default |
| Custom code | C callbacks | Rust processors and an event bus ([[rmk-async-runtime]]) |

## Nix compatibility

- **Dev shell:** about equal. RMK ships a full upstream dev shell that could be
  adapted ([[rmk-build-and-flash]], [[nix-dev-shell]]).
- **Firmware package:** QMK's is verified bit-identical and comes with a flash
  app ([[nix-firmware-package]]). RMK has none upstream.
- **What an RMK package would need:**
  - crate vendoring (crane or naersk, not checked);
  - one build per half;
  - the objcopy and uf2 step;
  - a flash app.
- **Open questions:** whether embedded Rust builds are byte-for-byte reproducible
  is not examined. Nix cannot fix the stored-keymap problem.

## Verdict

- RMK is worth it if you want wireless or Vial.
- Otherwise QMK keeps the git-driven, reproducible workflow at no feature cost
  for this keymap.

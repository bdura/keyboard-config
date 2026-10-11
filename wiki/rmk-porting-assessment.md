---
summary: What porting the bdura keymap from QMK to RMK would take — the hard blocker is the AVR controllers; every keymap feature except (unused) RGB has a direct equivalent; the workflow changes.
sources:
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/configuration/behavior.md
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/configuration/layout.md
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/features/layers.md
  - .agent-workspace/.repos/rmk/rmk/src/config/behavior.rs
  - .agent-workspace/.repos/rmk/scripts/via2rmk.py
tags:
  - rmk
  - assessment
---

# Porting the bdura keymap to RMK

An assessment, made at the commit in [[rmk-firmware]], of moving [[ferris-keymap]]
from QMK to RMK. Nothing here has been built or tested.

## Blockers

- **Hard: the controllers.** RMK cannot run on the ATmega32u4
  ([[rmk-hardware-support]]). Both Pro Micros must be replaced:
  - with nice!nano v2 boards, for a BLE split with a battery in each half;
  - or with RP2040 clones, for a wired PIO half-duplex split ([[rmk-split]]).
- **Soft: RGB underglow.** RMK has no RGB support, but the RGB settings in
  [[keymap-config]] are already inactive, so nothing is lost.

## Feature by feature

- **Geometry.** Each half becomes a 4×5 direct-pin matrix. The peripheral gets a
  column (or row) offset. Pro Micro pin labels must be translated to GPIO names
  by hand. Add `L`/`R` hand markers in `[layout].map` for `unilateral_tap`.
- **[[base-layers]].**
  - QWERTY goes on layer 0 and Colemak-DH on layer 1.
  - Switching between them needs `DF(0)`/`DF(1)` (or `PDF`) keys on some
    reachable layer. Layers below the default layer cannot be reached[^layers],
    the same open question as in QMK.
- **[[home-row-mods]].**
  - Left hand: `MT(A, LGui, HRM)`, `MT(S, LAlt, HRM)`, `MT(D, LShift, HRM)`,
    `MT(F, LCtrl, HRM)`, `MT(G, RAlt, HRM)`; the right hand mirrors it.
  - Profile: `HRM = { permissive_hold = true, hold_timeout = "200ms" }`.
  - `unilateral_tap` and flow tap could be added. See [[rmk-tap-hold]].
- **[[thumb-cluster]].**
  - Layer-tap thumbs: `LT(sym, Escape)`, `LT(num, Enter)`, `LT(sym, Backspace)`.
  - RMK has no `MEH` shorthand (only `via2rmk.py` translates it), so `MEH_T(KC_SPC)`
    becomes `MT(Space, LCtrl | LShift | LAlt)`. An `[aliases]` entry can name it.
  - The thumbs probably need the `*` hand marker or their own profile.
- **[[caps-word-combo]].**
  `{ actions = ["U", "I", "O"], output = "CapsWordToggle", layer = 0 }`.
  The QWERTY-only limitation stays the same ([[rmk-combos]]). Caps Word itself
  only differs by its fixed 5 s timeout ([[rmk-caps-word]]).
- **Mouse keys.** The keycodes exist, but tuning acceleration needs the Rust API.
  This doesn't matter today, because no mouse keys are mapped.
- **`SPLIT_USB_DETECT`.** No counterpart: roles are fixed per binary.

## Workflow changes

- **Stored keymap.** The keymap in flash wins over a reflash, so each keymap
  change needs a `clear_layout` flash, or Vial disabled ([[rmk-keymap-storage]]).
  This breaks the "git is the truth" loop of [[repo-lifecycle]].
- **Two binaries.** The central and the peripheral are built and flashed separately.
- **Nix.** A reproducible firmware derivation would have to be written from scratch;
  RMK's own flake only provides a dev shell ([[rmk-build-and-flash]]).

[^layers]: [docs/features/layers.md](../.repos/rmk/docs/docs/main/docs/features/layers.md),
           l.9–11

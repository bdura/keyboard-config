---
summary: Hub page for the bdura keymap on the Ferris 34-key split keyboard — its layers, thumb cluster, home-row mods and combos.
sources:
  - keyboards/ferris/keymaps/bdura/keymap.c
  - keyboards/ferris/keymaps/bdura/config.h
  - keyboards/ferris/keymaps/bdura/rules.mk
tags:
  - hub
  - keymap
  - ferris
---

# Ferris keymap (bdura)

The only keymap in the repo lives in `keyboards/ferris/keymaps/bdura/`,
split across three files: `keymap.c` (layers and combos), `config.h` (timing and
feature settings) and `rules.mk` (enabled QMK features)[^keymap][^config][^rules].
It is built for `ferris/sweep` (Pro Micro, 34 keys; `LAYOUT` is an alias of
`LAYOUT_split_3x5_2`); see [[ferris-hardware]].

## Layers

The keymap declares five layers, in this order[^keymap]:

| Index | Layer          | How to reach it                      | Page                     |
| ----- | -------------- | ------------------------------------ | ------------------------ |
| 0     | `_QWERTY`      | Default (first layer)                | [[base-layers]]          |
| 1     | `_COLEMAK_DH`  | No key switches to it (see page)     | [[base-layers]]          |
| 2     | `_ARROWS`      | Hold R (QWERTY) / P (Colemak-DH)     | [[arrows-layer]]         |
| 3     | `_NUMBERS`     | Hold Enter (left inner thumb)        | [[numbers-layer]]        |
| 4     | `_SYMBOLS`     | Hold Esc or Backspace (outer thumbs) | [[symbols-layer]]        |

## Cross-cutting pages

- [[home-row-mods]] — the GUI/Alt/Shift/Ctrl/AltGr mod-taps on the home row,
  and the tap-hold timing that supports them.
- [[thumb-cluster]] — the four thumb keys shared by both base layers.
- [[caps-word-combo]] — D+K combo toggling Caps Word (work in progress).
- [[keymap-config]] — the rest of `config.h`: mouse keys, split USB detection,
  RGB underglow.

## Conventions in keymap.c

Base-layer rows are defined as preprocessor macros (`_________QWERTY_L1_________`
etc.), one per half-row, and assembled through `LAYOUT_ferris_wrapper`,
a variadic wrapper that lets the macros expand before `LAYOUT` sees them.
The secondary layers call `LAYOUT` directly with literal keycodes.
The keymap array sits between `// clang-format off` / `// clang-format on`
so the hand-aligned grid survives formatting[^keymap] (see [[code-formatting]]).

[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)
[^config]: [keyboards/ferris/keymaps/bdura/config.h](../../keyboards/ferris/keymaps/bdura/config.h)
[^rules]: [keyboards/ferris/keymaps/bdura/rules.mk](../../keyboards/ferris/keymaps/bdura/rules.mk)

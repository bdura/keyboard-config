---
summary: Layer 4, held from either outer thumb; a number row on top, a few brackets on the right home row, mods on both hands.
sources:
  - keyboards/ferris/keymaps/bdura/keymap.c
tags:
  - keymap
  - layers
---

# Symbols layer (`_SYMBOLS`)

Reached by holding Esc (left outer thumb) or Backspace (right outer thumb)[^keymap].
See [[thumb-cluster]].

## Contents

- Top row: digits 1 through 0 across all ten columns[^keymap].
- Left home row: the [[home-row-mods]] with `KC_NO` taps (written here with
  the explicit `LGUI_T`, `LALT_T`, `LSFT_T`, `LCTL_T`, `RALT_T` names)[^keymap].
- Right home row, mod-taps whose tap produces a symbol[^keymap]:
  - inner index: `-` / AltGr
  - index: `[` / Ctrl
  - middle: `]` / Shift
  - ring: nothing / Alt
  - pinky: nothing / GUI
- Bottom row and thumbs: empty.

Symbols are produced by shifting the top-row digits (via the left-hand Shift)
or the bracket keys (e.g. Shift+`[` for `{`). The layer is sparse; most
symbols have no dedicated key yet[^keymap].

[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)

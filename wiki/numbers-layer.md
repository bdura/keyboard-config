---
summary: Layer 3, held from the left inner thumb (Enter); a right-hand numpad with left-hand home-row mods.
sources:
  - keyboards/ferris/keymaps/bdura/keymap.c
tags:
  - keymap
  - layers
---

# Numbers layer (`_NUMBERS`)

Reached by holding Enter on the left inner thumb (`LT(_NUMBERS, KC_ENT)`)[^keymap].
See [[thumb-cluster]].

## Right hand: numpad

The right hand holds a 3×3 numpad on the three middle columns[^keymap]:

```
  1 2 3  -
  4 5 6  0
  7 8 9  0
```

The inner column is empty. The pinky column has Minus on top and 0 on both
the home and bottom rows; the duplicate 0 is in the source and its purpose is
not recorded[^keymap].

## Left hand: mods

The left home row repeats the [[home-row-mods]] (GUI, Alt, Shift, Ctrl, AltGr)
with `KC_NO` taps, so modifiers can be combined with digits[^keymap].

The uncommitted working tree (as of 2026-10-11) also puts Tab on the left
top-row pinky key; this is not yet in a commit.

[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)

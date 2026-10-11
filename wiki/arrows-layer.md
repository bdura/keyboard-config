---
summary: Layer 2, held from the top-row index key; vim-style arrows on the right home row and the bootloader key.
sources:
  - keyboards/ferris/keymaps/bdura/keymap.c
tags:
  - keymap
  - layers
---

# Arrows layer (`_ARROWS`)

Reached by holding the left top-row index key: R on QWERTY, P on
Colemak-DH (`LT(_ARROWS, …)`)[^keymap].

Contents, right hand only; everything else is `KC_NO`[^keymap]:

- Home row, from inner index to ring: Left, Down, Up, Right — the vim
  `h j k l` positions on QWERTY.
- Top row, inner index (the Y position on QWERTY): `QK_BOOT`, which reboots
  the controller into the bootloader for flashing.

The hold key is on the left hand, so the right hand is free for the arrows.
There are no modifiers on this layer, so shift-selecting with arrows
requires holding a mod some other way — _needs verification_ of how this is
used in practice.

[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)

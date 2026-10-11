---
summary: The two alpha layers, QWERTY (default) and Colemak-DH, which share the same home-row mods, arrow-layer key and thumb cluster.
sources:
  - keyboards/ferris/keymaps/bdura/keymap.c
tags:
  - keymap
  - layers
---

# Base layers: QWERTY and Colemak-DH

Two alpha layers are defined from row macros[^keymap]:

- `_QWERTY` (layer 0) — the default, since QMK starts on the lowest layer.
- `_COLEMAK_DH` (layer 1) — Colemak Mod-DH.

Both apply the same pattern, so switching layout keeps muscle memory for everything
except letters[^keymap]:

- [[home-row-mods]] on the middle row, same modifier per finger.
- The top-row index key (R on QWERTY, P on Colemak-DH) is `LT(_ARROWS, …)`:
  hold for the [[arrows-layer]].
- The same four thumb keys (`___BASE_LT___`, `___BASE_RT___`), see [[thumb-cluster]].

The block comment above the keymap draws only the QWERTY layer[^keymap].

## Differences that matter

Because the layouts place letters differently, some keys carry a mod on one layer
and not the other. Notably D and K are home-row Shift keys on QWERTY (`SFT_T(KC_D)`,
`RSFT_T(KC_K)`) but plain bottom-row keys on Colemak-DH (`KC_D`, `KC_K`)[^keymap].
Likewise I and O are plain on QWERTY but home-row mods on Colemak-DH.
Combos match keycodes, not positions, so this decides where a combo fires;
see [[caps-word-combo]].

## Reaching Colemak-DH

No key in the keymap switches the default layer (`DF()`, `PDF()`) or toggles
layer 1 (`TG()`, `TO()`)[^keymap]. As written, `_COLEMAK_DH` cannot be activated
from the keyboard. Whether this is intentional (e.g. a layout kept in reserve)
is not recorded — _needs verification_.

[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)

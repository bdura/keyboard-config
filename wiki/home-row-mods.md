---
summary: Home-row modifiers on both base layers (GUI, Alt, Shift, Ctrl, AltGr from pinky to inner index) and the tap-hold settings tuned for them.
sources:
  - keyboards/ferris/keymaps/bdura/keymap.c
  - keyboards/ferris/keymaps/bdura/config.h
tags:
  - keymap
  - mod-tap
---

# Home-row mods

Each home-row key on both [[base-layers]] is a mod-tap: tap for the letter,
hold for a modifier[^keymap]. The order mirrors across hands:

| Finger      | Left (QWERTY / Colemak-DH) | Right (QWERTY / Colemak-DH) | Modifier |
| ----------- | -------------------------- | --------------------------- | -------- |
| Pinky       | A / A                      | ; / O                       | GUI (Cmd)|
| Ring        | S / R                      | L / I                       | Alt      |
| Middle      | D / S                      | K / E                       | Shift    |
| Index       | F / T                      | J / N                       | Ctrl     |
| Inner index | G / G                      | H / M                       | AltGr    |

This is the "GASC"-style order (GUI, Alt, Shift, Ctrl) plus AltGr on the inner
column[^keymap].

Small asymmetries in the keycodes: the right ring finger uses `ALT_T` (left Alt)
rather than a right-Alt variant, because on most OSes right Alt is AltGr,
already assigned to the inner column. The right Shift, Ctrl and GUI use the `R*`
variants[^keymap].

## Mods on the secondary layers

The [[numbers-layer]] and [[symbols-layer]] repeat the same five modifiers on the
left home row with `KC_NO` as the tap action, so a mod can be held while typing
numbers or symbols with the right hand[^keymap]. On the symbols layer the right
hand carries mods too (see that page).

## Timing

`config.h` sets the tap-hold behaviour "for enabling homerow modifiers"[^config]:

- `TAPPING_TERM 200` — a key held longer than 200 ms is a hold.
- `PERMISSIVE_HOLD` — pressing and releasing another key while the mod-tap is
  held counts as a hold, even within the tapping term.
- `QUICK_TAP_TERM 0` — disables tap-then-hold auto-repeat, so a quick re-press
  always yields the modifier.

These three lines match the upstream Ferris default keymap, and `TAPPING_TERM 200`
is also QMK's default. The QMK in `.firmware/` also offers home-row-mod helpers that
are not used yet: Flow Tap, Chordal Hold and Speculative Hold ([[qmk-tap-hold]]).
Caps Word capitalises tapped mod-tap letters correctly ([[qmk-caps-word]]).

[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)
[^config]: [keyboards/ferris/keymaps/bdura/config.h](../../keyboards/ferris/keymaps/bdura/config.h)

---
summary: The four thumb keys shared by both base layers — Esc/Symbols, Enter/Numbers, Space/Meh, Backspace/Symbols.
sources:
  - keyboards/ferris/keymaps/bdura/keymap.c
tags:
  - keymap
  - thumbs
---

# Thumb cluster

Both [[base-layers]] use the same thumb keys, defined by the `___BASE_LT___`
and `___BASE_RT___` macros[^keymap]:

| Position     | Tap       | Hold                  |
| ------------ | --------- | --------------------- |
| Left outer   | Esc       | [[symbols-layer]]     |
| Left inner   | Enter     | [[numbers-layer]]     |
| Right inner  | Space     | Meh (Ctrl+Alt+Shift)  |
| Right outer  | Backspace | [[symbols-layer]]     |

Notes:

- The symbols layer is reachable from either hand's outer thumb, so it can be
  held by whichever hand is not typing the symbol.
- Space became `MEH_T(KC_SPC)` in commit `838b95e` ("fix: meh t"). The diagram
  in the keymap comment still shows a plain `⎵`[^keymap].
- On the secondary layers all four thumb keys are `KC_NO`[^keymap].

## See also

Under RMK the layer-tap thumbs map directly; `MEH_T` has no shorthand and becomes
`MT(Space, LCtrl | LShift | LAlt)` ([[rmk-porting-assessment]]).

[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)

---
summary: A D+K chord toggles QMK Caps Word; work in progress, and the combo probably only fires on the Colemak-DH layer.
sources:
  - keyboards/ferris/keymaps/bdura/keymap.c
  - keyboards/ferris/keymaps/bdura/rules.mk
tags:
  - keymap
  - combo
  - caps-word
  - wip
---

# Caps Word on D+K

Pressing D and K together sends `CW_TOGG`, which toggles QMK's Caps Word:
letters are capitalised until a word-breaking key (e.g. space) is
typed[^keymap]. Both features are enabled in `rules.mk` (`COMBO_ENABLE`,
`CAPS_WORD_ENABLE`)[^rules].

```c
const uint16_t PROGMEM dk_combo[] = {KC_D, KC_K, COMBO_END};

combo_t key_combos[] = {
    COMBO(dk_combo, CW_TOGG),
};
```

The feature lives on the `feat/dk-caps-word` branch, introduced by commit
`de11e0a` ("wip: add caps word on D+K combo").

## Why D+K

On QWERTY, D and K are the left and right home-row Shift keys
([[home-row-mods]]). Chording both Shifts to get "caps" is a common
home-row-mods idiom.

## Open question: does it fire on QWERTY?

The source comment says the combo uses bare keycodes "so the combo fires
regardless of which home-row mod wrapper (SFT_T, RSFT_T, …) is active on that
key"[^keymap].

This is likely wrong. QMK matches combo keys against the keycode in the keymap
at the pressed position, and its combo documentation tells you to write the
full mod-tap keycode (e.g. `LSFT_T(KC_D)`) in the combo for keys that are
mod-taps. If so, `{KC_D, KC_K}` will not match `SFT_T(KC_D)` and
`RSFT_T(KC_K)` on QWERTY. It will match on Colemak-DH, where D and K are bare
bottom-row keys ([[base-layers]]), but that layer cannot currently be
activated. _Needs verification_ on hardware or against the QMK version in
`.firmware/`.

Possible fixes if it is confirmed: list the mod-tap keycodes in the combo, or
define one combo per base layer.

[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)
[^rules]: [keyboards/ferris/keymaps/bdura/rules.mk](../../keyboards/ferris/keymaps/bdura/rules.mk)

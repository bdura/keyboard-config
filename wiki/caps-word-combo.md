---
summary: A D+K chord toggles QMK Caps Word; work in progress, and per QMK source the combo does not fire on QWERTY (only on the unreachable Colemak-DH layer).
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
letters are capitalised until a word-breaking key (e.g. space) is typed[^keymap].
Both features are enabled in `rules.mk` (`COMBO_ENABLE`, `CAPS_WORD_ENABLE`)[^rules].

```c
const uint16_t PROGMEM dk_combo[] = {KC_D, KC_K, COMBO_END};

combo_t key_combos[] = {
    COMBO(dk_combo, CW_TOGG),
};
```

The feature lives on the `feat/dk-caps-word` branch, introduced by commit
`de11e0a` ("wip: add caps word on D+K combo").

## Why D+K

On QWERTY, D and K are the left and right home-row Shift keys ([[home-row-mods]]).
Chording both Shifts to get "caps" is a common home-row-mods idiom.

## Open question: does it fire on QWERTY?

The source comment says the combo uses bare keycodes "so the combo fires regardless
of which home-row mod wrapper (SFT_T, RSFT_T, …) is active on that key"[^keymap].

The comment is wrong. The QMK source in `.firmware/` (`bd500ae`) confirms it:
combos compare the full 16-bit keycode at the pressed position with `==`,
so `{KC_D, KC_K}` does not match `SFT_T(KC_D)` and `RSFT_T(KC_K)` on QWERTY
([[qmk-combos]]). It will match on Colemak-DH, where D and K are bare bottom-row
keys ([[base-layers]]), but that layer cannot currently be activated.
Not yet tested on hardware.

Possible fixes (details in [[qmk-combos]]):

- list the mod-tap keycodes in the combo;
- define one combo per base layer;
- use `COMBO_ONLY_FROM_LAYER`.

Adding `COMBO_MUST_TAP_PER_COMBO` keeps holding D+K usable as two Shifts. QMK also
has a built-in alternative, `BOTH_SHIFTS_TURNS_ON_CAPS_WORD` ([[qmk-caps-word]]).

[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)
[^rules]: [keyboards/ferris/keymaps/bdura/rules.mk](../../keyboards/ferris/keymaps/bdura/rules.mk)

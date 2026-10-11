---
summary: A U+I+O chord toggles QMK Caps Word; it fires on QWERTY only, because combos match the full keycode at each key position.
sources:
  - keyboards/ferris/keymaps/bdura/keymap.c
  - keyboards/ferris/keymaps/bdura/rules.mk
tags:
  - keymap
  - combo
  - caps-word
---

# Caps Word combo (U+I+O)

Pressing U, I and O together sends `CW_TOGG`, which toggles QMK's Caps Word:
letters are capitalised until a word-breaking key (e.g. space) is typed[^keymap]
([[qmk-caps-word]]). Both features are enabled in `rules.mk` (`COMBO_ENABLE`,
`CAPS_WORD_ENABLE`)[^rules].

```c
const uint16_t PROGMEM uio_combo[] = {KC_U, KC_I, KC_O, COMBO_END};

combo_t key_combos[] = {
    COMBO(uio_combo, CW_TOGG),
};
```

Developed on branch `feat/uio-caps-word` (renamed from `feat/dk-caps-word`).
Commit `3c2a967` moved the combo from D+K to U+I+O. It compiles for `ferris/sweep`
(with `-e ALLOW_WARNINGS=yes`, see [[repo-lifecycle]]), but has not been tested
on hardware yet.

## Why not D+K

The first version (commit `de11e0a`) chorded D+K, the two QWERTY home-row
Shift keys ([[home-row-mods]]). Its comment claimed bare `KC_D`/`KC_K` would
match "regardless of which home-row mod wrapper (SFT_T, RSFT_T, …) is active".
That was wrong: combos compare the full 16-bit keycode at the pressed position,
so `{KC_D, KC_K}` never matched `SFT_T(KC_D)`/`RSFT_T(KC_K)` on QWERTY
([[qmk-combos]]). It would only have fired on Colemak-DH, where D and K are plain
keys, and that layer cannot be reached ([[base-layers]]).

U, I and O are plain top-row keys on QWERTY, so they need no mod-tap wrappers, and a
three-key chord on the top row is unlikely to fire while typing normally[^keymap].

## Limits

- QWERTY only. On Colemak-DH, I and O are home-row mods (`ALT_T(KC_I)`,
  `RCMD_T(KC_O)`), so the combo does not match there; the source comment says
  so[^keymap]. `COMBO_ONLY_FROM_LAYER` would make it positional across layers
  ([[qmk-combos]]).
- QMK's built-in alternative, `BOTH_SHIFTS_TURNS_ON_CAPS_WORD`, was not chosen
  ([[qmk-caps-word]]).

[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)
[^rules]: [keyboards/ferris/keymaps/bdura/rules.mk](../../keyboards/ferris/keymaps/bdura/rules.mk)

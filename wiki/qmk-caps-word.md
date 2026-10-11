---
summary: QMK Caps Word — shifts letters until a word breaks, without using Caps Lock; mod-tap aware; built-in activation options besides a key or combo.
sources:
  - .agent-workspace/.repos/qmk_firmware/quantum/caps_word.c
  - .agent-workspace/.repos/qmk_firmware/quantum/process_keycode/process_caps_word.c
  - .agent-workspace/.repos/qmk_firmware/docs/features/caps_word.md
tags:
  - qmk
  - caps-word
---

# QMK Caps Word

Part of [[qmk-firmware]]. Used by [[caps-word-combo]].

## Behaviour

Enable it with `CAPS_WORD_ENABLE = yes` and toggle it with `CW_TOGG`.

While it is on[^docs]:

- letters are shifted and `-` becomes `_`;
- digits, Backspace, Delete and `_` continue the word;
- any other key ends it (customisable in `caps_word_press_user`).

`CAPS_WORD_IDLE_TIMEOUT` (default 5000 ms, 0 = never) turns it off after inactivity.

It does not use `KC_CAPS`, so it keeps working when Caps Lock is remapped at the
OS level. On the other hand, it shifts by HID keycode rather than by character,
which can surprise users of non-US OS layouts[^docs].

## Mod-tap awareness

`process_caps_word.c` handles mod-tap keys as follows[^process]:

- a **tapped** mod-tap is unwrapped to its tap keycode, so home-row-mod letters
  are capitalised;
- a **held** Shift mod-tap counts as Shift;
- a **held** AltGr-only mod-tap is ignored, which matters for the inner-column
  AltGr keys in [[home-row-mods]];
- any other held mod-tap (Ctrl, Alt, GUI) ends Caps Word.

## Activation options without a combo

- `BOTH_SHIFTS_TURNS_ON_CAPS_WORD` — press both Shifts. Works with mod-tap Shifts
  if both are held past the tapping term. Conflicts with Command.
- `DOUBLE_TAP_SHIFT_TURNS_ON_CAPS_WORD`.
- Call `caps_word_on()` from code.

## See also

RMK's version, with fixed rules and a fixed timeout, is [[rmk-caps-word]].

[^docs]: [docs/features/caps_word.md](../.repos/qmk_firmware/docs/features/caps_word.md),
         l.20–88, l.151–170
[^process]: [quantum/process_keycode/process_caps_word.c](../.repos/qmk_firmware/quantum/process_keycode/process_caps_word.c),
            l.174–208

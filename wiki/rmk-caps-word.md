---
summary: RMK Caps Word — a CapsWordToggle keycode with fixed word-breaking rules and a hard-coded 5 s timeout; held mod-tap modifiers do not break it.
sources:
  - .agent-workspace/.repos/rmk/rmk-types/src/keycode/hid.rs
  - .agent-workspace/.repos/rmk/rmk/src/keyboard.rs
  - .agent-workspace/.repos/rmk/rmk/tests/scenarios/caps_word.toml
tags:
  - rmk
  - caps-word
---

# RMK Caps Word

Part of [[rmk-firmware]]. RMK's counterpart of [[qmk-caps-word]].

## Behaviour

`CapsWordToggle` turns it on and off[^kb]. While it is on[^hid]:

- letters are shifted, and `-` becomes `_`;
- digits, Backspace and Delete continue the word;
- any other key that goes through the HID-key path ends it.

After 5 s of inactivity it turns off. That `Duration::from_secs(5)` is
hard-coded[^kb]. Pressing the key again after a timeout turns it back on[^test].

## With mod-tap keys

This was inferred from `keyboard.rs`, not tested:

- A **tapped** mod-tap letter is shifted, like any other letter.
- A **held** mod-tap modifier is an `Action::Modifier`. It does not go
  through the Caps Word check, so it does not end the word. QMK differs here:
  it ends the word on a held Ctrl, Alt or GUI.
- A tapped `MT(Space, …)` sends Space, which ends the word.

## Missing compared with QMK

These are inferred from absence:

- No `caps_word_press_user` hook to customise which keys continue a word.
- No configurable idle timeout.
- No both-Shifts or double-tap-Shift activation. A key or a combo is the only way
  to turn it on, which is what [[caps-word-combo]] uses anyway.

[^hid]: [rmk-types/src/keycode/hid.rs](../.repos/rmk/rmk-types/src/keycode/hid.rs),
        l.430–452
[^kb]: [rmk/src/keyboard.rs](../.repos/rmk/rmk/src/keyboard.rs), l.81–83,
       l.1223–1298, l.1488–1495, l.1528–1557
[^test]: [rmk/tests/scenarios/caps_word.toml](../.repos/rmk/rmk/tests/scenarios/caps_word.toml)

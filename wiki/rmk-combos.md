---
summary: RMK combos match the full KeyAction of each pressed key (so mod-tap members must be written in full), run before tap-hold, and can be restricted to the highest active layer.
sources:
  - .agent-workspace/.repos/rmk/rmk/src/keyboard.rs
  - .agent-workspace/.repos/rmk/rmk/src/keyboard/combo.rs
  - .agent-workspace/.repos/rmk/rmk/src/keymap.rs
  - .agent-workspace/.repos/rmk/rmk/src/config/behavior.rs
  - .agent-workspace/.repos/rmk/rmk/tests/scenarios/morse_combo_hrm.toml
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/configuration/behavior.md
tags:
  - rmk
  - combos
---

# RMK combos

Part of [[rmk-firmware]]. RMK's counterpart of [[qmk-combos]]. Relevant to
[[caps-word-combo]].

## Matching

- A key event goes to `process_combo` first, and only then to tap-hold
  processing[^kb].
- A combo compares the pressed key's resolved `KeyAction` with its `actions` list,
  **by equality**[^combo]. This is the same keycode-identity model as QMK,
  so the pitfall recorded in [[caps-word-combo]] applies as-is: `"D"` does not
  match `"MT(D, LShift)"`.
- Equality includes the morse profile index (inferred). A member written as
  `MT(I, LAlt, HRM)` must be written the same way in the combo. Whether the TOML
  combo parser accepts profile names was not checked.
- Home-row-mod members work: inside the combo window the combo replaces them,
  and outside it each key resolves as a normal tap-hold[^test].

## Options

Defaults[^cfg][^beh]:

- `timeout`: 50 ms;
- `prior_idle_time`: none;
- `combo_max_num`: 8;
- `combo_max_length`: 4 (maximum 16).

`ComboOn`, `ComboOff` and `ComboToggle` switch combos at runtime.

A per-combo `layer` is compared with the **highest active layer, including the
default layer**[^keymap]. This is how a combo is limited to one base layer.

## Limits

RMK has no positional mode like QMK's `COMBO_ONLY_FROM_LAYER`. To fire the same
chord on another base layer, you write a second combo with that layer's actions
and its `layer`. On Colemak-DH, those actions sit at different physical keys.

[^kb]: [rmk/src/keyboard.rs](../.repos/rmk/rmk/src/keyboard.rs), l.389–394
[^combo]: [rmk/src/keyboard/combo.rs](../.repos/rmk/rmk/src/keyboard/combo.rs),
          l.49–68; [rmk-types/src/combo.rs](../.repos/rmk/rmk-types/src/combo.rs),
          l.70–72
[^test]: [rmk/tests/scenarios/morse_combo_hrm.toml](../.repos/rmk/rmk/tests/scenarios/morse_combo_hrm.toml)
[^cfg]: [rmk/src/config/behavior.rs](../.repos/rmk/rmk/src/config/behavior.rs),
        l.188–196
[^beh]: [docs/configuration/behavior.md](../.repos/rmk/docs/docs/main/docs/configuration/behavior.md),
        l.72–99
[^keymap]: [rmk/src/keymap.rs](../.repos/rmk/rmk/src/keymap.rs), l.327–334

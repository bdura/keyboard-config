---
summary: QMK combos match the exact 16-bit keycode at the pressed position, so mod-tap keys must appear with their full keycode; options and knobs.
sources:
  - .agent-workspace/.repos/qmk_firmware/quantum/process_keycode/process_combo.c
  - .agent-workspace/.repos/qmk_firmware/quantum/quantum.c
  - .agent-workspace/.repos/qmk_firmware/docs/features/combo.md
tags:
  - qmk
  - combo
---

# QMK combos

Part of [[qmk-firmware]]. Used by [[caps-word-combo]].

## Matching

`process_combo` receives the full keycode at the pressed position on the active
layer[^quantum]:

- **Layer:** the highest layer in `layer_state | default_layer_state`. It can be
  remapped with `COMBO_ONLY_FROM_LAYER` or `combo_ref_from_layer`[^combo].
- **Comparison:** keys are compared with a plain `==` against each `keys[]`
  entry[^combo].

So **`SFT_T(KC_D)` does not match `KC_D`**. The docs say that for mod-tap
and layer-tap keys "you will need to place the full keycode in the combo
definition"[^docs].

## Ways to combo mod-tap keys

- List the mod-tap keycodes, e.g. `{SFT_T(KC_D), RSFT_T(KC_K), COMBO_END}`.
- Set `COMBO_ONLY_FROM_LAYER` to a layer whose keys are bare.
- Define one combo per base layer.
- Override `combo_ref_from_layer()`.

## Knobs

- `COMBO_TERM` — chord window; default 50 ms.
- `COMBO_MUST_TAP_PER_COMBO` — tap-only combos. Recommended when combo keys are
  mod-taps, so holding the chord still yields mods[^docs].
- `COMBO_MUST_HOLD_MODS`, `COMBO_STRICT_TIMER`, `COMBO_SHOULD_TRIGGER`.

You don't need to set `COMBO_COUNT`: the core computes it through keymap
introspection ([[qmk-build-pipeline]]).

[^quantum]: [quantum/quantum.c](../.repos/qmk_firmware/quantum/quantum.c), l.280
[^combo]: [quantum/process_keycode/process_combo.c](../.repos/qmk_firmware/quantum/process_keycode/process_combo.c),
          l.280–287, l.577–586
[^docs]: [docs/features/combo.md](../.repos/qmk_firmware/docs/features/combo.md),
         l.21–24, l.149, l.207–212

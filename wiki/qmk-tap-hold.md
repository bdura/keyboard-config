---
summary: Tap-hold options available in QMK at the checked-out commit — tapping term, permissive hold, quick tap, and the home-row-mod helpers Flow Tap, Chordal Hold and Speculative Hold.
sources:
  - .agent-workspace/.repos/qmk_firmware/quantum/action_tapping.c
  - .agent-workspace/.repos/qmk_firmware/quantum/action_tapping.h
  - .agent-workspace/.repos/qmk_firmware/docs/tap_hold.md
  - .agent-workspace/.repos/qmk_firmware/lib/python/qmk/cli/generate/keyboard_c.py
tags:
  - qmk
  - mod-tap
---

# QMK tap-hold options

Part of [[qmk-firmware]]. Used by [[home-row-mods]].

## Options at this commit

The options below are all implemented in `quantum/action_tapping.c` and documented
in `docs/tap_hold.md`. Most have per-key variants.

| Option                    | Effect                                                            | Used here |
| ------------------------- | ----------------------------------------------------------------- | --------- |
| `TAPPING_TERM`            | Hold threshold; default 200 ms[^h]                                | 200 (= default) |
| `PERMISSIVE_HOLD`         | Another key tapped inside the term makes it a hold                | yes       |
| `HOLD_ON_OTHER_KEY_PRESS` | Any other key *pressed* inside the term makes it a hold           | no        |
| `QUICK_TAP_TERM`          | Tap-then-hold auto-repeat window; defaults to `TAPPING_TERM`, `0` disables[^docs] | 0 |
| `FLOW_TAP_TERM`           | Flow Tap (below)                                                  | no        |
| `CHORDAL_HOLD`            | Chordal Hold (below)                                              | no        |
| `SPECULATIVE_HOLD`        | Applies Shift/Ctrl on keydown, before the tap/hold decision       | no        |
| `RETRO_TAPPING`           | Releasing a held key with no other key pressed sends the tap      | no        |

The three settings the keymap uses are identical to the upstream Ferris default
keymap's `config.h` ("Pick good defaults for enabling homerow modifiers").

## Flow Tap

If a mod-tap is pressed within `FLOW_TAP_TERM` of a preceding letter or space,
it is forced to a tap. This is aimed at home-row mods: it prevents accidental
mods during fast typing and removes the input lag. It is suspended while another
tap-hold key is undecided, so mods can still be chorded. By default it is off
while Ctrl, GUI or left Alt is held[^docs].

## Chordal Hold

An "opposite hands" rule: a tap-hold key followed, within the term, by another key
on the same hand settles as a tap. It is meant to be combined with `PERMISSIVE_HOLD`
or `HOLD_ON_OTHER_KEY_PRESS`. Multi-mod chords on one side still work, and combos
are exempt[^docs].

QMK takes each key's hand from the first of these that is defined:

1. a `chordal_hold_handedness()` function;
2. a `chordal_hold_layout` array;
3. a per-key `"hand"` field in `keyboard.json`;
4. a guess from the layout's x coordinates[^kbc].

The Sweep's layout has a clear gap between halves, so the guess should split
cleanly (inferred, not tested).

[^h]: [quantum/action_tapping.h](../.repos/qmk_firmware/quantum/action_tapping.h),
      l.22–27
[^docs]: [docs/tap_hold.md](../.repos/qmk_firmware/docs/tap_hold.md), l.414–543,
         l.545–720, l.796–827
[^kbc]: [lib/python/qmk/cli/generate/keyboard_c.py](../.repos/qmk_firmware/lib/python/qmk/cli/generate/keyboard_c.py),
        l.207–246

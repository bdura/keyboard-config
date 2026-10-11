---
summary: RMK resolves tap-hold, layer-tap and tap dance with one "morse" engine — named profiles, permissive_hold, hold_on_other_press, unilateral_tap via hand markers, flow tap with prior_idle_time — and how QMK options map onto it.
sources:
  - .agent-workspace/.repos/rmk/rmk/src/keyboard.rs
  - .agent-workspace/.repos/rmk/rmk/src/config/behavior.rs
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/configuration/behavior.md
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/configuration/layout.md
tags:
  - rmk
  - tap-hold
  - home-row-mods
---

# RMK tap-hold (the morse engine)

Part of [[rmk-firmware]]. RMK's counterpart of [[qmk-tap-hold]]. Relevant to
[[home-row-mods]] and [[thumb-cluster]].

## Decision: one engine for every multi-role key

`MT(key, mods[, profile])`, `LT(n, key[, profile])`, `TH(tap, hold[, profile])`
and tap-dance keys are all "morse" keys. They are resolved in a buffer of held
keys (`make_decisions_for_keys` / `fire_held_keys`)[^kb]. Morse keys can also
match full `.-` patterns, which makes them a superset of tap dance.

**Why:** a single state machine for all multi-role keys, which also maps cleanly
onto Vial's tap-dance model. Only the four Vial-style patterns can be edited in
Vial[^beh].

## Profiles and modes

The default profile is `[behavior.morse]`. Named profiles go in
`[behavior.morse.profiles]` (at most 16), and a key references one by name as its
last argument[^beh].

The mode decides how a key resolves when another key is pressed while it is held:

- `normal_mode` (default) — decides by timeout only.
- `permissive_hold` — hold if another key is pressed **and released** inside the
  window.
- `hold_on_other_press` — hold as soon as any other key is pressed.

Other options:

- **`unilateral_tap`** (experimental): if the next key is on the same hand,
  the held key resolves as a tap. The hand comes from the `L`/`R` markers
  in `[layout].map`; `*` (bilateral) counts as the opposite hand[^layout].
  It fires on press in `normal_mode` and on release in `permissive_hold`;
  `hold_on_other_press` ignores it.
- **Flow tap:** set `enable_flow_tap` (default `false`) and the global
  `prior_idle_time` (default 120 ms). A morse key pressed sooner than that
  after the last simple key taps at once[^cfg]. There is no per-key idle time.
- **Timings:** `hold_timeout` defaults to 250 ms. `gap_timeout` (250 ms)
  is for morse keys only. Both are 13-bit fields, so the maximum is 8191 ms.
- `quick_tap_timeout` is off by default.

The docs suggest this home-row-mod setup[^beh]:

- profile `{ unilateral_tap = true, permissive_hold = true, hold_timeout = "250ms" }`;
- global `enable_flow_tap = true` with `prior_idle_time = "120ms"`.

## Mapping from QMK

| QMK ([[qmk-tap-hold]]) | RMK |
|---|---|
| `TAPPING_TERM` | `hold_timeout` |
| `PERMISSIVE_HOLD` | `permissive_hold = true` |
| `HOLD_ON_OTHER_KEY_PRESS` | `hold_on_other_press = true` |
| `QUICK_TAP_TERM 0` | the default (`quick_tap_timeout` off) |
| Flow Tap | `enable_flow_tap` + `prior_idle_time` |
| Chordal Hold | `unilateral_tap` + hand markers (closest equivalent; judgement) |
| per-key `get_*` callbacks | named profiles |
| Speculative Hold | none found |

## Limits

- `unilateral_tap` is marked experimental.
- `prior_idle_time` cannot be set per key.
- Interactions with combos are covered by scenario tests
  (`rmk/tests/scenarios/morse_combo_*.toml`). See [[rmk-combos]].

[^kb]: [rmk/src/keyboard.rs](../.repos/rmk/rmk/src/keyboard.rs), l.397–825,
       l.1540–1544
[^beh]: [docs/configuration/behavior.md](../.repos/rmk/docs/docs/main/docs/configuration/behavior.md),
        l.228–340
[^layout]: [docs/configuration/layout.md](../.repos/rmk/docs/docs/main/docs/configuration/layout.md),
           l.98–106
[^cfg]: [rmk/src/config/behavior.rs](../.repos/rmk/rmk/src/config/behavior.rs),
        l.143–152

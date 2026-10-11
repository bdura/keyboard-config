---
summary: RMK stores the keymap and behaviours in flash for Vial, and the stored copy wins over a reflash — clear_layout is needed to apply a keymap change from keyboard.toml.
sources:
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/features/storage.md
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/getting_started/faq.md
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/features/vial_support.mdx
tags:
  - rmk
  - storage
  - vial
---

# RMK keymap storage and Vial

Part of [[rmk-firmware]]. This is a contrast with this repo's workflow,
where the keymap in git is the single source of truth ([[repo-lifecycle]],
[[nix-firmware-package]]).

## Decision: the stored keymap wins

The FAQ says[^faq]:

> RMK stores your keymap in flash and assumes you change it live with a host
> configurator… the stored keymap takes precedence, reflashing the firmware won't
> change an already-stored keymap by default.

RMK wipes the storage by itself only when one of these changes[^storage]:

- the RMK version, commit or features;
- `macro_space_size`, `combo_max_length` or `max_patterns_per_key`.

Two `[storage]` options override this:

- `clear_layout = true`: re-seeds the keymap, behaviours, combos, forks,
  morses and macros from the firmware, and keeps BLE bonds. Flash once with it,
  then turn it back off.
- `clear_storage = true`: wipes everything on every boot.

The storage is a `sequential-storage` key-value log in the last N flash sectors.
N defaults to 8 with `[dfu]` and to 2 otherwise. Board files can override it:
`nice!nano_v2` uses 32.

**Why:** Vial edits must survive a reboot, and BLE bonds must persist.

**Implication for a git-driven workflow:** when only `keyboard.toml` changes,
nothing triggers a wipe, so a reflash would silently keep the old keymap.
Every keymap change would need a `clear_layout` flash, or Vial would have to be
disabled (inferred).

## Vial

Vial is on by default. Unlocking it requires physical unlock keys[^vial].

`vial.json` is maintained separately from `keyboard.toml` and must match it.
`rmkit layout convert --to-vial keyboard.toml` can generate it[^vial]. The roadmap
item "Making vial and default keymap consistent automatically" is still open.

[^faq]: [docs/getting_started/faq.md](../.repos/rmk/docs/docs/main/docs/getting_started/faq.md),
        l.62–72
[^storage]: [docs/features/storage.md](../.repos/rmk/docs/docs/main/docs/features/storage.md),
            l.13, l.42–52
[^vial]: [docs/features/vial_support.mdx](../.repos/rmk/docs/docs/main/docs/features/vial_support.mdx),
         l.31–54

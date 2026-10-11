---
title: "fix: default firmware build fails on lufa.c with avr-gcc 16 (-Werror=unused-but-set-variable)"
severity: medium
---

The firmware does not build with the default flags from the Nix dev shell.
A workaround exists, but has to be remembered on every build and is not recorded
anywhere in the repository itself.

## Reproduction

From the project root, in the dev shell (`nix develop` / direnv):

```shell
QMK_HOME=$PWD/.firmware qmk compile -kb ferris/sweep -km bdura
```

Fails with:

```
tmk_core/protocol/lufa/lufa.c:327:10: error: variable 'ConfigSuccess' set but not used [-Werror=unused-but-set-variable=]
cc1: all warnings being treated as errors
make: *** [builddefs/common_rules.mk:362: .build/obj_ferris_sweep_bdura/lufa.o] Error 1
```

Observed 2026-10-11 with avr-gcc 16.2.0 and QMK CLI 1.2.0 from the flake's
`nixos-unstable`, and the QMK checkout in `.firmware/` at `bd500ae092` (2026-03-19).

## Cause

In `EVENT_USB_Device_ConfigurationChanged`, QMK core accumulates `ConfigSuccess`
from endpoint configuration calls but never reads it. GCC 16 flags this,
and QMK builds with `-Werror`. The keymap is not involved.

## Workaround

Adding `-e ALLOW_WARNINGS=yes` builds successfully (27108/28672 bytes, 94%).
See the wiki page `repo-lifecycle`.

## Possible fixes

- Update `.firmware/` to a QMK version that fixes `lufa.c`, if one exists.
- Pin an older AVR toolchain in `flake.nix`.
- Set `ALLOW_WARNINGS = yes` in the keymap's `rules.mk`, so the workaround lives
  in the repo. This also hides real warnings in the keymap.

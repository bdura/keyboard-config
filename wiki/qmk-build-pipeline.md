---
summary: How QMK turns kb:km into firmware — two-stage make, rules.mk/config.h layering order, data-driven config, keymap introspection, and where outputs land.
sources:
  - .agent-workspace/.repos/qmk_firmware/Makefile
  - .agent-workspace/.repos/qmk_firmware/builddefs/build_keyboard.mk
  - .agent-workspace/.repos/qmk_firmware/builddefs/generic_features.mk
  - .agent-workspace/.repos/qmk_firmware/builddefs/common_rules.mk
  - .agent-workspace/.repos/qmk_firmware/lib/python/qmk/build_targets.py
  - .agent-workspace/.repos/qmk_firmware/quantum/keymap_introspection.c
  - .agent-workspace/.repos/qmk_firmware/docs/data_driven_config.md
tags:
  - qmk
  - build
---

# QMK build pipeline

Part of [[qmk-firmware]].

## Entry points

- `make <kb>:<km>[:<target>]` — the top-level `Makefile` parses this grammar.
  `<target>` is an optional make goal such as `flash`, `avrdude-split-left`
  or `clean`[^makefile].
- `qmk compile -kb <kb> -km <km>` — a Python front-end that calls
  `make -f builddefs/build_keyboard.mk KEYBOARD=… KEYMAP=…`. Pass extra make
  variables with `-e VAR=value`[^buildtargets].

## Stage 1: top-level Makefile

A catch-all `%:` rule[^makefile]:

1. checks that the `qmk` CLI works;
2. syncs submodules with `qmk git-submodule --sync` (skip with `SKIP_GIT`;
   see [[qmk-firmware-checkout]]);
3. resolves the keyboard (including aliases) and the keymap by calling `qmk`
   subcommands; keymap listing includes userspace keymaps;
4. runs one sub-make per pair on `builddefs/build_keyboard.mk`.

The top level is `.NOTPARALLEL`. Sub-makes still honour `-j`.

## Stage 2: configuration layering

`build_keyboard.mk` layers configuration from the outermost keyboard folder
inwards, then the keymap, then `users/`[^buildkb].

**`rules.mk`**, in include order:

1. keyboard `rules.mk` files, outer to inner;
2. data-driven `info_rules.mk` (generated);
3. keymap `rules.mk`;
4. community modules;
5. `users/<USER_NAME>/rules.mk` (`USER_NAME` defaults to the keymap name);
6. `disable_features.mk`;
7. keyboard `post_rules.mk`.

**`config.h`**, in the order they are force-included (`-include`):

1. community modules;
2. keyboard `config.h` files, outer to inner;
3. generated `info_config.h`;
4. `users/` `config.h`;
5. keymap `config.h`;
6. `POST_CONFIG_H`.

Generated data-driven values and core defaults are wrapped in `#ifndef`.
Consequences:

- A keymap `#define` of something nothing else defined simply takes effect.
- Redefining something the keyboard's own `config.h` already defined needs
  `#undef` first.

**Features:** `X_ENABLE = yes` for a generic feature (this includes `COMBO`
and `CAPS_WORD`) adds `quantum/process_keycode/process_x.c`, the core source,
and `-DX_ENABLE`[^generic].

## Data-driven configuration

`info.json` / `keyboard.json` are turned into `info_config.h`, `info_rules.mk`
and `default_keyboard.c/h` at build time[^buildkb].

The docs explain why. With nearly 4000 keyboards, free-form `rules.mk`/`config.h`
files became unmaintainable. Tools such as Configurator and VIA also need
machine-readable data. So `info.json` became the single source of truth[^dd].

The drawback: every build runs several `qmk generate-*` processes, so builds
depend on the Python CLI.

## Keymap introspection

`keymap.c` is not compiled as its own unit. The build defines `-DKEYMAP_C="…"`,
and `quantum/keymap_introspection.c` `#include`s it. The core can then compute
`ARRAY_SIZE(keymaps)`, `ARRAY_SIZE(key_combos)`, etc. itself and static-assert
limits[^introspection].

Consequences:

- You never declare `COMBO_COUNT` or layer counts by hand.
- A keymap array kept in another file must be named through `INTROSPECTION_KEYMAP_C`,
  not added to `SRC`.

## Outputs

- **Build directory:** objects go to `.build/obj_<kb>_<km>/` and artefacts to
  `.build/<kb with / → _>_<km>.{elf,hex,…}`[^buildkb].
- **Copies:** the firmware file is copied to the firmware root and to the userspace
  root ([[qmk-external-userspace]]). For this repo that is `ferris_sweep_bdura.hex`.
- **Size check:** `check-size` runs on every build. For AVR, the bootloader size
  is subtracted from the flash size (see [[ferris-hardware]]).

## Warnings are errors

QMK compiles with `-Werror` unless `ALLOW_WARNINGS=yes` is set. With the
Nix shell's avr-gcc 16.2.0, building `ferris/sweep:bdura` on 2026-10-11
failed on `tmk_core/protocol/lufa/lufa.c:327` (`unused-but-set-variable`).
With `-e ALLOW_WARNINGS=yes` it built: 27108/28672 bytes (94%)[^observed].
See [[repo-lifecycle]].

[^makefile]: [Makefile](../.repos/qmk_firmware/Makefile), l.153–266 and l.380–403
[^buildtargets]: [lib/python/qmk/build_targets.py](../.repos/qmk_firmware/lib/python/qmk/build_targets.py),
                 l.106–158
[^buildkb]: [builddefs/build_keyboard.mk](../.repos/qmk_firmware/builddefs/build_keyboard.mk)
[^generic]: [builddefs/generic_features.mk](../.repos/qmk_firmware/builddefs/generic_features.mk),
            l.21–68
[^dd]: [docs/data_driven_config.md](../.repos/qmk_firmware/docs/data_driven_config.md),
       l.5–11
[^introspection]: [quantum/keymap_introspection.c](../.repos/qmk_firmware/quantum/keymap_introspection.c)
[^observed]: Observed on 2026-10-11 by running
             `QMK_HOME=$PWD/.firmware qmk compile -kb ferris/sweep -km bdura` in
             the Nix dev shell, with and without `-e ALLOW_WARNINGS=yes`.

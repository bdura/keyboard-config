# Reproducible firmware: design record

Decisions reached in the grill-me session of 2026-10-11. Each section is numbered
so task files can cite it. This file is a record, not maintained afterwards.

## 1. Reproducibility level

Bit-identical output, not just pinned inputs. `SKIP_VERSION=yes` replaces
`QMK_VERSION`, `QMK_BUILDDATE` and the userspace version with constants,
which is the only variable content in the hex. Nothing on a Sweep reads those
strings. `nix build --rebuild` is the check.

## 2. Pinning QMK

A single flake input, `qmk-firmware`, on
`git+https://github.com/qmk/qmk_firmware?ref=master&submodules=1`, `flake = false`.

- All eight submodules are fetched (about 1 GB) although AVR needs only `lufa`
  and `printf`. Correctness over disk: separate inputs per submodule would pin revs
  in `flake.lock` that nothing ties to QMK's `.gitmodules`, so `nix flake update`
  could desync them silently.
- `master` rather than a tag: the lock pins the rev anyway, and QMK tags only on
  breaking-change merges.
- Not a git submodule of this repo: flakes drop submodules from `self` unless
  every command passes `?submodules=1`, and QMK's own submodules would still need
  one of the above.

## 3. No crane-style split

Measured on 2026-10-11 (Apple Silicon, all cores): clean build 24 s,
rebuild after touching `keymap.c` 2.7 s, after touching `config.h` 22.6 s.
The keymap's `config.h` is force-included in every compilation unit, so the only
possible split line is `config.h`+`rules.mk` versus `keymap.c`. The saving applies
to `keymap.c`-only edits, and carrying `.build/` between two sandboxes breaks on
mtimes (store resets them) and on Darwin's non-stable sandbox paths in `.d` files.
Make's own cache on disk is the iteration cache; `nix build` is for the artefact.

## 4. Toolchain

`nixpkgs` pinned to `nixos-25.11` for `qmk` (which brings avr-gcc 14.3.0)
and the firmware build. `nixpkgs-unstable` for shell-only tools (`prek`, `qmkfmt`,
`dos2unix`). Upstream QMK master still has the `ConfigSuccess` dead store in
`lufa.c` that avr-gcc 16 rejects under `-Werror`, so a QMK bump would not fix it.
Rejected: `ALLOW_WARNINGS=yes` (hides keymap warnings), a `postPatch` on
`lufa.c` (carried on every bump, and the next GCC brings the next warning),
and demoting one warning class. The dev shell's `qmk` comes from the stable input
so the iteration loop and the release build share one compiler.

## 5. Build targets from `qmk.json`

The flake reads `build_targets` from `qmk.json` with `builtins.fromJSON` and
emits one package per `[keyboard, keymap]` pair, named `<kb with / → ->-<km>`,
plus `packages.default` for the first. One source of truth; `qmk userspace-add`
and `qmk userspace-compile` keep working. The `v1.1` form with an env map can
carry extra make variables later.

## 6. Flashing as a flake app

One `flash-<target>` app per target plus `apps.default`, wrapping `qmk flash <hex>`.
`nix run .` builds and flashes, once per half. The Sweep has no `EE_HANDS`,
so both halves take the same hex and no EEPROM file.

## 7. Dev loop: lazy sync from the Makefile

The dev shell exports `QMK_FIRMWARE_SRC` (the store path of the pinned tree)
and `QMK_HOME=$PWD/.firmware`. The repo Makefile keeps a marker file in
`.firmware/` holding the store path it was copied from; when the marker differs
from `QMK_FIRMWARE_SRC`, it recreates the copy (`cp -R`, `chmod -R u+w`).
`make sync` runs that rule alone for people calling `qmk compile` directly.
`.firmware/` stays gitignored and disposable. Replaces `qmk setup --home` and
`qmk config user.qmk_home`, and removes the config-path mismatch between the Nix
`qmk` and `~/Library/Application Support/qmk/qmk.ini`.

Rejected: sync in `shellHook` (a 1 GB copy on `cd` after a bump) and an explicit
`qmk-sync` command (one more step to remember, and the Makefile needs the
staleness check anyway for a useful error).

## 8. No CI

The user sees no use for a CI artefact. `nix build --rebuild` is documented in
the README as the manual determinism check.

## 9. Userspace source filter

The derivation's userspace source is `lib.fileset` restricted to `keyboards/`,
`layouts/`, `users/` and `qmk.json`, so README or flake edits do not rebuild.

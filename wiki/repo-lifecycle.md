---
summary: End-to-end workflow of this repo — environment, firmware checkout, edit, build, flash, update — with the blockers observed on 2026-10-11.
sources:
  - README.md
  - Makefile
  - qmk.json
  - flake.nix
  - .envrc
  - .gitignore
tags:
  - tooling
  - workflow
---

# Repo lifecycle

How this repo is used from a fresh machine to a flashed keyboard. Each step links
to the page with the details.

## 1. Environment

`.envrc` holds `use flake`, so direnv enters the Nix dev shell on `cd`[^envrc].
The shell provides `qmk` (with the AVR/ARM toolchains and flashers), `qmkfmt`
and `dos2unix` ([[nix-dev-shell]]). It provides tools, not firmware sources.

## 2. Firmware checkout (once per machine)

```shell
qmk setup --home ./.firmware/
```

This clones `qmk_firmware` into the gitignored `.firmware/` and records it as
`user.qmk_home`[^readme]. The link between the repo and the checkout is that
`qmk.ini` setting only. Details: [[qmk-firmware-checkout]].

## 3. Edit

The keymap is in `keyboards/ferris/keymaps/bdura/` ([[ferris-keymap]]).
Formatting tools: [[code-formatting]].

## 4. Build

Either of:

```shell
make ferris/sweep:bdura                     # via the repo Makefile → .firmware
qmk compile -kb ferris/sweep -km bdura
```

The repo's `Makefile` forwards every target to `make -C <qmk_home>` with
`QMK_USERSPACE` set to the repo[^makefile] ([[qmk-userspace]]). The firmware
is copied to the repo root as `ferris_sweep_bdura.hex`, which is gitignored.
`build_targets` in `qmk.json` is empty, so `qmk userspace-compile` builds
nothing[^qmkjson]. Pipeline details: [[qmk-build-pipeline]]. Target hardware:
[[ferris-hardware]].

## 5. Flash

```shell
qmk flash -kb ferris/sweep -km bdura   # reset the plugged half when prompted
```

Repeat for the other half. Plug USB into the left half when using the board
([[split-handedness]]). Details: [[qmk-flashing]].

## 6. Update

Nothing automates updates:

- **Firmware:** `git -C .firmware pull` + `make -C .firmware git-submodule`
  ([[qmk-firmware-checkout]]). The QMK version is not pinned, so two machines can
  build against different QMK versions.
- **Toolchain:** `nix flake update`. This can change the compiler under an
  unchanged QMK tree; see the blockers below.

The README's stated plan is to package the firmware in the flake. That would pin
the version and remove step 2.

## Blockers observed on 2026-10-11

- **`qmk_home` unset in the Nix shell.** The Nix `qmk` 1.2.0 reads `~/.config/qmk/`,
  but the existing `qmk.ini` is in `~/Library/Application Support/qmk/`. So `make …`
  stops with "Cannot determine qmk_firmware location" ([[qmk-firmware-checkout]]).
- **avr-gcc 16.2.0 vs `-Werror`.** The current nixpkgs-unstable toolchain
  rejects `tmk_core/protocol/lufa/lufa.c:327` (`unused-but-set-variable`).
  `-e ALLOW_WARNINGS=yes` works around it ([[qmk-build-pipeline]]).

Command that built successfully[^observed]:

```shell
QMK_HOME=$PWD/.firmware qmk compile -kb ferris/sweep -km bdura -e ALLOW_WARNINGS=yes
```

[^envrc]: [.envrc](../../.envrc)
[^readme]: [README.md](../../README.md)
[^makefile]: [Makefile](../../Makefile)
[^qmkjson]: [qmk.json](../../qmk.json)
[^observed]: Observed on 2026-10-11 in the Nix dev shell; 27108/28672 bytes (94%).

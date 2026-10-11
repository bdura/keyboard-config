---
summary: End-to-end workflow of this repo — dev shell, edit, iterate with make, build the reproducible hex with nix build, flash with nix run, update the pins.
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
to the page with the details. This replaces the pre-2026-10-11 workflow, which
needed `qmk setup --home ./.firmware/` and carried two blockers (see the end).

## 1. Environment

`.envrc` holds `use flake`, so direnv enters the Nix dev shell on `cd`[^envrc].
The shell provides `qmk` with avr-gcc 14 and the flashers, `qmkfmt`, `prek` and
`dos2unix`, and exports `QMK_FIRMWARE_SRC` and `QMK_HOME` ([[nix-dev-shell]]).
There is no per-machine setup step any more.

## 2. Edit

The keymap is in `keyboards/ferris/keymaps/bdura/` ([[ferris-keymap]]).
Formatting tools: [[code-formatting]].

## 3. Iterate

```shell
make ferris/sweep:bdura                   # syncs .firmware/ if needed, then builds
qmk compile -kb ferris/sweep -km bdura    # same, after a `make sync`
```

The first run copies the pinned QMK tree into `.firmware/` (about 13 s),
later runs are incremental ([[qmk-userspace]]). The hex is copied to the repo
root as `ferris_sweep_bdura.hex`, gitignored.

## 4. Build the artefact

```shell
nix build              # result/ferris_sweep_bdura.hex
nix build --rebuild    # fails if a second build differs byte for byte
```

See [[nix-firmware-package]]. Target hardware: [[ferris-hardware]].

## 5. Flash

```shell
nix run .    # builds, then `qmk flash` on the hex; reset the plugged half
```

Repeat for the other half. Plug USB into the left half when using the board
([[split-handedness]]). Mechanism: [[qmk-flashing]]. Not yet tried from this repo
with a board attached.

## 6. Update

- **QMK:** `nix flake update qmk-firmware`, then rebuild. The next `make`
  recreates `.firmware/`. Check the breaking-changes changelog for renames
  ([[qmk-firmware-checkout]]).
- **Toolchain:** `nix flake update nixpkgs`. Stay on a release branch whose avr-gcc
  QMK supports (`nixos-26.05` → 15.3.0, current; `nixos-25.11` → 14.3.0, also fine;
  unstable → 16.x, which breaks `-Werror`; `nixos-26.05` → 15.3.0, untested).
- **Shell tools:** `nix flake update nixpkgs-unstable`.

## History: blockers before 2026-10-11

Both were removed by the reproducible-firmware plan:

- `user.qmk_home` unset in the Nix shell, because the Nix `qmk` read
  `~/.config/qmk/` while `qmk.ini` lived in `~/Library/Application Support/qmk/`.
  `QMK_HOME` is now exported by the shell.
- avr-gcc 16.2.0 rejecting `tmk_core/protocol/lufa/lufa.c:327` under `-Werror`,
  worked around with `ALLOW_WARNINGS=yes`. The toolchain now comes from a stable
  release branch (`nixos-25.11` first, `nixos-26.05` since the same day).

[^envrc]: [.envrc](../../.envrc)

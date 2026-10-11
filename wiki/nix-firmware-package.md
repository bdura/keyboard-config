---
summary: How flake.nix turns each qmk.json build target into a bit-identical firmware package and a flash app — inputs, the derivation's phases, what keeps the hex deterministic, and the verification run on 2026-10-11.
sources:
  - flake.nix
  - nix/targets.nix
  - nix/userspace.nix
  - nix/firmware.nix
  - nix/flash.nix
  - qmk.json
  - .agent-workspace/plans/reproducible-firmware/design.md
tags:
  - tooling
  - nix
  - build
---

# Nix firmware package

Part of [[tooling]]. The design decisions behind it are argued in the workspace
plan `reproducible-firmware` (`design.md`). Dev-shell side: [[nix-dev-shell]].
Iteration side: [[qmk-userspace]].

## Inputs

- `qmk-firmware` — `git+https://github.com/qmk/qmk_firmware?ref=master&submodules=1`,
  `flake = false`. All eight submodules are fetched (about 1 GB) although AVR needs
  only `lufa` and `printf`; separate inputs per submodule would not be tied to
  QMK's `.gitmodules` and could desync on `nix flake update`. Pinned at `7a1bbf37`
  (2026-10-02) as of 2026-10-11. Update with `nix flake update qmk-firmware`.
- `nixpkgs` (nixos-26.05) for `qmk` 1.2.0, hence avr-gcc 15.3.0. First done on
  nixos-25.11 (avr-gcc 14.3.0), moved the same day after checking that gcc 15
  also passes `-Werror`.

## Layout

`flake.nix` only declares inputs and wires modules under `nix/` with `callPackage`
(split on 2026-10-11; the derivation path was unchanged by the split, checked
with `nix path-info --derivation`):

- `nix/targets.nix` — `qmk.json` → list of `{keyboard, keymap, env, name, target}`.
  System-independent.
- `nix/userspace.nix` — the `lib.fileset` of the overlay.
- `nix/firmware.nix` — target → derivation. `passthru` carries `keyboard`,
  `keymap`, `target` and `firmware` (the hex path, via `finalAttrs.finalPackage`).
- `nix/flash.nix` — package → app, reading `passthru.firmware`.
- `nix/devshell.nix` — see [[nix-dev-shell]]. Named `devshell` because the user's
  global git ignore lists `shell.nix`, and flakes only see tracked files.
- `nix/qmkfmt.nix` — see [[code-formatting]].

## From `qmk.json` to packages

`build_targets` in `qmk.json` is read with `builtins.fromJSON`. Each
`[keyboard, keymap]` (optionally `[keyboard, keymap, {env}]`, forwarded as make
variables) yields:

- `packages.<system>.<kb-slug>-<km>`, e.g. `ferris-sweep-bdura`, whose only output
  is `<target>.hex`;
- `apps.<system>.flash-<kb-slug>-<km>`, a `qmk flash <hex>` wrapper.
  Extra arguments go to `qmk flash`.

The first manifest entry is also `packages.default` and `apps.default`,
so `nix build` and `nix run .` do the obvious thing. `qmk userspace-add` extends
the list without touching the flake ([[qmk-external-userspace]]).

## The derivation

- `src` is the pinned tree; stdenv's unpack makes it writable, which QMK needs
  for `.build/`.
- `nativeBuildInputs = [ qmk ]`: the top-level `make` calls `qmk generate-*`
  ([[qmk-build-pipeline]]). The CLI finds the tree from the cwd and writes its
  config under `HOME`, so `HOME=$TMPDIR`.
- The userspace is a `lib.fileset` of `keyboards/`, `layouts/`, `users/` and
  `qmk.json`, copied to `$TMPDIR/userspace` and made writable because QMK copies
  the firmware back into `$(QMK_USERSPACE)`.
- `make <kb>:<km> QMK_USERSPACE=… SKIP_VERSION=yes -j$NIX_BUILD_CORES`.
  `SKIP_VERSION` makes `QMK_VERSION`, `QMK_BUILDDATE` and the userspace version
  constants and implies `SKIP_GIT`; the tree is not a git repo anyway.
- `installPhase` copies only the `.hex`. The `.elf` and `.map` were dropped
  because they can embed sandbox paths.

## Verified on 2026-10-11

- `nix build .#ferris-sweep-bdura`: 34 s build phase; 27496/28672 bytes with gcc
  14, 27290/28672 bytes (95%) with gcc 15.
- `nix build .#ferris-sweep-bdura --rebuild`: passed, so the hex is bit-identical
  across builds.
- The dev-shell path (`make ferris/sweep:bdura`) produced the same SHA-256 as the
  Nix build (`8c093ed0…` with gcc 14, `57d76f87…` with gcc 15).
- `nix run . -- --help` prints `qmk flash` usage. Flashing a board was not tried.

## Not done

- No two-stage (crane-style) derivation: the keymap's `config.h` is force-included
  in every compilation unit, so only `keymap.c`-only edits would benefit
  (measured 24 s clean vs 2.7 s incremental vs 22.6 s after a `config.h` touch).
  The on-disk working copy covers that case.
- No CI. `nix build --rebuild` is the manual check.

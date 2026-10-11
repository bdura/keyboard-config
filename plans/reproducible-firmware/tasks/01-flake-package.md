---
task-id: 01
blocked-by: []
---

# 01: Flake package and app

Make `nix build` produce the hex from pinned inputs, and `nix run` flash it.

## Changes

- `flake.nix`
  - Inputs: `nixpkgs` → `github:NixOS/nixpkgs/nixos-25.11`;
    new `nixpkgs-unstable` → `nixos-unstable`; new `qmk-firmware` →
    `git+https://github.com/qmk/qmk_firmware?ref=master&submodules=1`,
    `flake = false` (`design.md §2`, §4). Keep `qmkfmt-src`.
  - Read `build_targets` from `qmk.json` (`design.md §5`). For each `[kb, km]`:
    a derivation `stdenv.mkDerivation` with `src = qmk-firmware`,
    `nativeBuildInputs = [ qmk ]` from stable, `dontConfigure`, `buildPhase` that
    copies the filtered userspace (`design.md §9`) into a writable dir, exports
    `HOME=$TMPDIR`, and runs `make <kb>:<km> QMK_USERSPACE=<dir> SKIP_VERSION=yes`;
    `installPhase` copies `.build/<target>.hex` to `$out/`.
  - `packages.<system>.<kb-slug>-<km>` and `packages.default`.
  - `apps.<system>.flash-<kb-slug>-<km>` and `apps.default`: a `writeShellScript`
    running `qmk flash $pkg/<target>.hex` (`design.md §6`).
  - Dev shell: `qmk` from stable; `qmkfmt`, `dos2unix`, `prek` from unstable;
    `shellHook` exports `QMK_FIRMWARE_SRC=${qmk-firmware}` and
    `QMK_HOME=$PWD/.firmware`.
- `qmk.json`: `build_targets: [["ferris/sweep", "bdura"]]`.
- `flake.lock`: regenerated.

## Tests

- `nix build .#ferris-sweep-bdura` succeeds; `result/ferris_sweep_bdura.hex` exists.
- `nix build .#ferris-sweep-bdura --rebuild` succeeds.
- `nix flake check` passes (or `nix flake show` lists the packages and apps).

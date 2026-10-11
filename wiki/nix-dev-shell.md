---
summary: The flake's dev shell — qmk and avr-gcc 15 from nixos-26.05, qmkfmt/prek/dos2unix from unstable, and the QMK_FIRMWARE_SRC / QMK_HOME exports that drive the .firmware/ working copy.
sources:
  - flake.nix
  - nix/devshell.nix
  - nix/qmkfmt.nix
  - .envrc
tags:
  - tooling
  - nix
---

# Nix dev shell

`flake.nix` defines `devShells.default` for four systems (x86_64/aarch64 ×
linux/darwin) by calling `nix/devshell.nix`[^flake]; `qmkfmt` comes from
`nix/qmkfmt.nix` ([[nix-firmware-package]] describes the `nix/` layout).
Since the reproducible-firmware plan (2026-10-11) the flake has two nixpkgs inputs:

- `nixpkgs` on **`nixos-26.05`** — provides `qmk` (1.2.0), which brings
  avr-gcc 15.3.0, avrdude, dfu-util… This is also what the firmware package
  ([[nix-firmware-package]]) builds with, so the shell and `nix build` share one
  compiler.
- `nixpkgs-unstable` — shell-only tools: `prek` (0.5.5), `dos2unix`,
  and the Rust platform that builds `qmkfmt` 0.3.0 from a `fetchFromGitHub` of
  `rcorre/qmkfmt` in `nix/qmkfmt.nix` (not a flake input: it is pinned to a tag,
  and keeping version, source hash and `cargoHash` in one file avoids desync)
  (`doCheck = false`; see [[code-formatting]]).

Why stable for the toolchain: unstable's avr-gcc 16.2.0 rejects QMK core's `lufa.c`
under `-Werror` ([[qmk-build-pipeline]]), and upstream `master` has not fixed it.
avr-gcc 15.3.0 (`nixos-26.05`) and 14.3.0 (`nixos-25.11`) both compile it cleanly.

## Exports

- `QMK_FIRMWARE_SRC` — the store path of the pinned `qmk_firmware` tree.
  The repo `Makefile` reads it to populate `.firmware/` ([[qmk-userspace]]).
- `QMK_HOME=$PWD/.firmware` — set in `shellHook`, so `qmk compile` and
  `qmk flash` find the working copy without any `qmk.ini` setting. This removes
  the config-location mismatch recorded in [[qmk-firmware-checkout]].

`.envrc` contains `use flake`, so direnv enters the shell on `cd`[^envrc].

[^flake]: [flake.nix](../../flake.nix), [nix/devshell.nix](../../nix/devshell.nix)
[^envrc]: [.envrc](../../.envrc)

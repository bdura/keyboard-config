---
summary: A Nix flake provides a dev shell with qmk, qmkfmt (built from source) and dos2unix; direnv loads it automatically.
sources:
  - flake.nix
  - .envrc
tags:
  - tooling
  - nix
---

# Nix dev shell

`flake.nix` defines `devShells.default` for four systems (x86_64/aarch64 ×
linux/darwin) via `nixpkgs.lib.genAttrs`, on `nixos-unstable`[^flake]. The flake
used `flake-utils` before commit `4656c36` ("simplify flake"). It contains:

- `qmk` — the QMK CLI (1.2.0 as of 2026-10-11), from nixpkgs. The package brings
  the AVR and ARM toolchains (avr-gcc 16.2.0) and flashers (avrdude, dfu-util…).
- `qmkfmt` — not in nixpkgs, so the flake builds it with `rustPlatform`
  from `github:rcorre/qmkfmt` at tag `v0.3.0`, with tests disabled
  (`doCheck = false`)[^flake]. See [[code-formatting]].
- `dos2unix`.
- `prek` — the pre-commit runner for `prek.toml`. This is an uncommitted change
  as of 2026-10-11.

Because nixpkgs-unstable is followed, `nix flake update` can upgrade the compiler
under an unchanged QMK tree. avr-gcc 16.2.0 currently breaks the build under
`-Werror` ([[repo-lifecycle]]).

`.envrc` contains `use flake`, so direnv enters the shell on `cd`[^envrc].

The flake does not package the QMK firmware itself. That checkout lives in
`.firmware/` ([[qmk-userspace]]). Packaging it in the flake is a stated TODO in the
README. It would need the firmware's git submodules vendored and `SKIP_GIT=yes`
set ([[qmk-firmware-checkout]]).

[^flake]: [flake.nix](../../flake.nix)
[^envrc]: [.envrc](../../.envrc)

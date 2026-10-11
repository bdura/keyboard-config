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

`flake.nix` defines `devShells.default` for every default system via
`flake-utils`, on `nixos-unstable`[^flake]. It contains:

- `qmk` — the QMK CLI, from nixpkgs.
- `qmkfmt` — not in nixpkgs, so the flake builds it with `rustPlatform` from
  `github:rcorre/qmkfmt` at tag `v0.2.0`, with tests disabled
  (`doCheck = false`)[^flake]. See [[code-formatting]].
- `dos2unix`.

`.envrc` contains `use flake`, so direnv enters the shell on `cd`[^envrc].

The flake does not package the QMK firmware itself. That checkout lives in
`.firmware/` ([[qmk-userspace]]). Packaging it in the flake is a stated TODO in
the README.

[^flake]: [flake.nix](../../flake.nix)
[^envrc]: [.envrc](../../.envrc)

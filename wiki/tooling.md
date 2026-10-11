---
summary: Hub page for building and formatting the firmware — QMK userspace layout, the Nix dev shell, and formatters.
sources:
  - Makefile
  - qmk.json
  - flake.nix
  - README.md
tags:
  - hub
  - tooling
---

# Tooling

- [[repo-lifecycle]] — end to end: environment, firmware checkout, edit, build,
  flash, update, and the current blockers.
- [[qmk-userspace]] — how this repo plugs into `qmk_firmware` as an external
  userspace, and where the firmware checkout lives.
- [[nix-dev-shell]] — the flake-provided shell with `qmk`, `qmkfmt` and `dos2unix`,
  loaded by direnv.
- [[code-formatting]] — clang-format, qmkfmt, clangd and editorconfig.

How upstream QMK does the building and flashing: [[qmk-firmware]].

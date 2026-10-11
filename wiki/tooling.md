---
summary: Hub page for building and formatting the firmware — QMK userspace layout, the Nix firmware package, the Nix dev shell, and formatters.
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

- [[repo-lifecycle]] — end to end: environment, edit, iterate, build, flash,
  update.
- [[nix-firmware-package]] — how the flake turns `qmk.json` targets into
  bit-identical firmware packages and flash apps.
- [[qmk-userspace]] — how this repo plugs into `qmk_firmware` as an external
  userspace, and the `.firmware/` working copy synced by the Makefile.
- [[nix-dev-shell]] — the flake-provided shell: `qmk` from stable, `qmkfmt`,
  `prek` and `dos2unix` from unstable, loaded by direnv.
- [[code-formatting]] — clang-format, qmkfmt, clangd and editorconfig.

How upstream QMK does the building and flashing: [[qmk-firmware]].

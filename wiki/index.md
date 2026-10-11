# Wiki index

Knowledge base for this project. Entry point: follow a hub page to reach everything
else.

This repository holds a personal [QMK](https://qmk.fm) configuration,
kept as a QMK external userspace. It currently targets a single keyboard:
the Ferris (34-key split).

## Hubs

- [[ferris-keymap]] — the `bdura` keymap for the Ferris: layers, thumbs, mods,
  combos and firmware settings.
- [[tooling]] — how the firmware is built and formatted: the reproducible
  [[nix-firmware-package]], QMK userspace, Nix dev shell, formatters, and the
  end-to-end [[repo-lifecycle]].
- [[qmk-firmware]] — exploration of upstream QMK at the commit in `.firmware/`:
  build pipeline, userspace mechanism, flashing, Ferris hardware, features.
- [[rmk-firmware]] — exploration of RMK, a Rust/Embassy firmware studied as an
  alternative to QMK, with a [[rmk-porting-assessment]] for this keymap.

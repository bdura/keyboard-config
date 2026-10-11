---
summary: The repo is a QMK external userspace; a Makefile forwards every target to a qmk_firmware checkout kept in the gitignored .firmware/ folder.
sources:
  - Makefile
  - qmk.json
  - README.md
  - .gitignore
tags:
  - tooling
  - build
---

# QMK userspace

The repo follows QMK's external userspace layout: keymaps live here, the QMK
firmware lives elsewhere[^readme]. How QMK detects and overlays a userspace:
[[qmk-external-userspace]]. The full workflow: [[repo-lifecycle]]. It was started
from the userspace template (commit `1ac55d3`, "chore: copy template").

## Layout

- `qmk.json` — userspace manifest, `userspace_version` 1.0, with an empty
  `build_targets` list[^qmkjson].
- `keyboards/` — per-keyboard keymaps; currently only `keyboards/ferris/keymaps/bdura/`
  (see [[ferris-keymap]]).
- `layouts/`, `users/` — empty placeholders (`.keep` files).

## Firmware checkout

The README sets up the firmware inside the repo[^readme]:

```shell
qmk setup --home ./.firmware/
```

`.firmware/` is gitignored[^gitignore]. Commit `a3f26c5` moved the firmware to
this local folder. The README calls this temporary, until the firmware is packaged
in the flake ([[nix-dev-shell]])[^readme].

It is a plain clone of `qmk/qmk_firmware` on `master`, not a submodule and not
pinned. The only link to this repo is `user.qmk_home` in `qmk.ini`. How it is set
up and updated, and a current config-location problem: [[qmk-firmware-checkout]].

## Makefile

Every target (`%:`) is forwarded to `make -C <qmk_home>` with `QMK_USERSPACE` set
to this repo[^makefile]. `qmk_home` is read from `qmk config -ro user.qmk_home`,
and the Makefile errors out if it is unset.

Since `build_targets` is empty, `qmk userspace-compile` has nothing to build yet.
Running `qmk userspace-add -kb ferris/sweep -km bdura` would add the target. Building
goes through `qmk compile -kb ferris/sweep -km bdura` or `make ferris/sweep:bdura`.
The target is `ferris/sweep`, which compiles at 94% of flash ([[ferris-hardware]]).
As of 2026-10-11 the build needs two workarounds; see [[repo-lifecycle]] and the
workspace issue `firmware-build-fails-lufa-werror`.

Built artifacts (`*.hex`, `*.bin`, `*.uf2`) are gitignored[^gitignore].
QMK copies each build's firmware into the userspace root, which is why these
files appear there ([[qmk-external-userspace]]).

[^readme]: [README.md](../../README.md)
[^qmkjson]: [qmk.json](../../qmk.json)
[^makefile]: [Makefile](../../Makefile)
[^gitignore]: [.gitignore](../../.gitignore)

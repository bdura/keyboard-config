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
firmware lives elsewhere[^readme]. It was started from the userspace template
(commit `1ac55d3`, "chore: copy template").

## Layout

- `qmk.json` — userspace manifest, `userspace_version` 1.0, with an empty
  `build_targets` list[^qmkjson].
- `keyboards/` — per-keyboard keymaps; currently only
  `keyboards/ferris/keymaps/bdura/` (see [[ferris-keymap]]).
- `layouts/`, `users/` — empty placeholders (`.keep` files).

## Firmware checkout

The README sets up the firmware inside the repo[^readme]:

```shell
qmk setup --home ./.firmware/
```

`.firmware/` is gitignored[^gitignore]. Commit `a3f26c5` moved the firmware to
this local folder. The README calls this temporary, until the firmware is
packaged in the flake ([[nix-dev-shell]])[^readme].

## Makefile

Every target (`%:`) is forwarded to `make -C <qmk_home>` with
`QMK_USERSPACE` set to this repo[^makefile]. `qmk_home` is read from
`qmk config -ro user.qmk_home`, and the Makefile errors out if it is unset.

Since `build_targets` is empty, `qmk userspace-compile` has nothing to build
yet. Building likely goes through `qmk compile -kb ferris/<rev> -km bdura`
or the equivalent make target; the exact Ferris revision used is _needs
verification_.

Built artifacts (`*.hex`, `*.bin`, `*.uf2`) are gitignored[^gitignore].

[^readme]: [README.md](../../README.md)
[^qmkjson]: [qmk.json](../../qmk.json)
[^makefile]: [Makefile](../../Makefile)
[^gitignore]: [.gitignore](../../.gitignore)

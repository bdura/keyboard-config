---
summary: The repo is a QMK external userspace; the Makefile syncs the pinned QMK tree into the gitignored .firmware/ working copy and forwards every other goal to it.
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

- `qmk.json` — userspace manifest, `userspace_version` 1.0, with
  `build_targets: [["ferris/sweep", "bdura"]]`[^qmkjson]. The flake reads this
  list to define its packages ([[nix-firmware-package]]).
- `keyboards/` — per-keyboard keymaps; currently only `keyboards/ferris/keymaps/bdura/`
  (see [[ferris-keymap]]).
- `layouts/`, `users/` — empty placeholders (`.keep` files).

## The `.firmware/` working copy

`.firmware/` is gitignored[^gitignore]. Until 2026-10-11 it was an unpinned
`git clone` created by `qmk setup --home ./.firmware/` (commit `a3f26c5`).
It is now a plain copy of the pinned tree that the flake fetches, with no `.git`:

- The dev shell exports `QMK_FIRMWARE_SRC`, the store path of the tree
  ([[nix-dev-shell]]).
- `.firmware/.nix-source` records which store path the copy came from.
- `make sync` compares the two and, on mismatch (including a missing directory),
  removes `.firmware/`, `cp -R`s the store path, `chmod -R u+w`s it and rewrites
  the marker. Measured at about 13 s for the full tree with submodules.

Because the copy is not a git repository, QMK's top-level `make` sets `SKIP_GIT` by
itself ([[qmk-firmware-checkout]]). Updating QMK is `nix flake update qmk-firmware`;
the next `make` resyncs.

## Makefile

- Refuses to run when `QMK_FIRMWARE_SRC` is unset, with a hint to enter the dev
  shell.
- `sync` is the only local goal.
- Every other goal (`%:`) depends on `sync` and is forwarded to
  `make -C .firmware <goal> QMK_USERSPACE=<repo>`[^makefile].

Both `make ferris/sweep:bdura` and `qmk compile -kb ferris/sweep -km bdura`
(via `QMK_HOME`, after a sync) build in the working copy. Incremental rebuild
after a `keymap.c` edit is a few seconds. The hex is also produced by `nix build`
([[nix-firmware-package]]); on 2026-10-11 both paths gave the same SHA-256.

Built artefacts (`*.hex`, `*.bin`, `*.uf2`) are gitignored[^gitignore]. QMK copies
each build's firmware into the userspace root ([[qmk-external-userspace]]).

[^readme]: [README.md](../../README.md)
[^qmkjson]: [qmk.json](../../qmk.json)
[^makefile]: [Makefile](../../Makefile)
[^gitignore]: [.gitignore](../../.gitignore)

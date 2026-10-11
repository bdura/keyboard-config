---
summary: How QMK locates its tree (qmk_home, QMK_HOME), submodules and SKIP_GIT, the master/develop release cycle, and how this repo now pins the tree through the flake instead of qmk setup.
sources:
  - .agent-workspace/.repos/qmk_firmware/docs/cli.md
  - .agent-workspace/.repos/qmk_firmware/docs/breaking_changes.md
  - .agent-workspace/.repos/qmk_firmware/lib/python/qmk/cli/git/submodule.py
  - .agent-workspace/.repos/qmk_firmware/Makefile
  - Makefile
  - README.md
tags:
  - qmk
  - tooling
---

# QMK firmware checkout

Part of [[qmk-firmware]]. In this repo the checkout is `.firmware/`
([[qmk-userspace]]).

## Creating and locating it

Upstream's way is `qmk setup [-H <path>]`, which clones `qmk/qmk_firmware`[^cli]
and records the location as `user.qmk_home` in `qmk.ini` (or reads `QMK_HOME` from
the environment). `setup` and the `QMK_HOME` handling belong to the separate `qmk`
CLI package, not `qmk_firmware`; the CLI first looks for a tree above the cwd,
then `qmk_home`, then `QMK_HOME`.

This repo no longer uses `qmk setup`. Since 2026-10-11 the tree is a flake
input pinned in `flake.lock`, and `.firmware/` is a plain copy of that store
path made by `make sync` ([[qmk-userspace]], [[nix-firmware-package]]).
The dev shell exports `QMK_HOME=$PWD/.firmware` for the CLI ([[nix-dev-shell]]).

### Config location mismatch (historical, observed 2026-10-11)

The Nix shell's `qmk` 1.2.0 reported `user.qmk_home=None`: its platformdirs
config directory was `~/.config/qmk/`, while a `qmk.ini` with the right
`qmk_home` existed in `~/Library/Application Support/qmk/`[^observed].
The old Makefile read `qmk_home` only through `qmk config -ro user.qmk_home`,
so `make ferris/sweep:bdura` stopped with "Cannot determine qmk_firmware location".
Exporting `QMK_HOME` from the shell and dropping the `qmk config` lookup from the
Makefile made this moot. The cause of the path difference was never verified.

## Submodules

`lib/chibios`, `lib/lufa`, `lib/vusb`, `lib/pico-sdk`… are git submodules.

- Every top-level `make` runs `qmk git-submodule --sync`, which shallow-inits
  (`--depth=50`) any missing submodule and warns if they are dirty[^submodule].
- `make git-submodule` / `qmk git-submodule` does a full sync and recursive update,
  and removes known-stale folders.
- `SKIP_GIT=yes` skips all of this. A tree that is not a git repo sets it
  automatically[^qmkmake].

For the Nix package this is handled by fetching the input with `submodules=1`
and by the tree not being a git repo, which sets `SKIP_GIT` automatically
([[nix-firmware-package]]). Verified on 2026-10-11: the sandboxed build runs
without git.

## Release cycle and updating

- `master` is stable.
- `develop` takes breaking changes and is merged into `master` about every three
  months, so that "users can have confidence that updating their QMK tree will
  not break their keymaps"[^breaking].
- Keyboard moves count as breaking changes. `keyboard_aliases.hjson` keeps old
  names working.

Doc vs calendar: at this commit, the doc gives 2026-05-31 as the next breaking-change
merge. That date has passed, so the checkout probably predates that merge.

To update the checkout:

```shell
nix flake update qmk-firmware
```

Then rebuild (`nix build`, or `make …`, which resyncs `.firmware/`), and check
the breaking-changes changelog for keyboard or keycode renames. After an update,
re-pin the study clone and refresh [[qmk-firmware]] (`commit-hash`).

## Version strings

The firmware embeds both `qmk_firmware`'s version and the userspace's own
`git describe` (`QMK_USERSPACE_VERSION`).

[^cli]: [docs/cli.md](../.repos/qmk_firmware/docs/cli.md), l.18
[^submodule]: [lib/python/qmk/cli/git/submodule.py](../.repos/qmk_firmware/lib/python/qmk/cli/git/submodule.py),
              l.32–37
[^qmkmake]: [Makefile](../.repos/qmk_firmware/Makefile), l.22–29, l.387–391
[^breaking]: [docs/breaking_changes.md](../.repos/qmk_firmware/docs/breaking_changes.md),
             l.3–20
[^observed]: Observed on 2026-10-11: `qmk --version` → 1.2.0,
             `qmk config -ro user.qmk_home` → `None`;
             `~/Library/Application Support/qmk/qmk.ini` contains
             `qmk_home = …/keyboard-config/.firmware`.

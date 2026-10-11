---
summary: How a qmk_firmware checkout is created, located (qmk_home), kept in sync (submodules) and updated (master/develop cycle), including the config-location mismatch seen with the Nix qmk CLI.
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

`qmk setup [-H <path>]` clones `qmk/qmk_firmware`[^cli]. This repo's README runs
it as `qmk setup --home ./.firmware/`[^readme].

- **Where it is recorded:** the location is stored in `user.qmk_home` in `qmk.ini`,
  or given through the `QMK_HOME` environment variable.
- **Where `setup` lives:** `setup` and the `QMK_HOME` handling belong to the
  separate `qmk` CLI package, not `qmk_firmware`. Not verified here.
- **Who reads it:** this repo's `Makefile` reads `qmk_home` only through
  `qmk config -ro user.qmk_home`, so `QMK_HOME` in the environment does not help
  it[^makefile].

The result is a plain git clone of `master`, not a submodule. It is not pinned
by anything in this repo.

### Config location mismatch (observed 2026-10-11)

The Nix shell's `qmk` 1.2.0 reports `user.qmk_home=None`. Its platformdirs config
directory is `~/.config/qmk/`, which doesn't exist. Meanwhile a `qmk.ini` with
the right `qmk_home` exists in `~/Library/Application Support/qmk/`[^observed].

As a result, `make ferris/sweep:bdura` stops with "Cannot determine qmk_firmware
location". The cause is _needs verification_: the file may have been written by
a different `qmk` build, or the config path may have changed between versions.
Workarounds:

- for the `qmk` CLI, `QMK_HOME=$PWD/.firmware`;
- for the Makefile, re-run `qmk config user.qmk_home=$PWD/.firmware` with the Nix
  `qmk`.

## Submodules

`lib/chibios`, `lib/lufa`, `lib/vusb`, `lib/pico-sdk`… are git submodules.

- Every top-level `make` runs `qmk git-submodule --sync`, which shallow-inits
  (`--depth=50`) any missing submodule and warns if they are dirty[^submodule].
- `make git-submodule` / `qmk git-submodule` does a full sync and recursive update,
  and removes known-stale folders.
- `SKIP_GIT=yes` skips all of this. A tree that is not a git repo sets it
  automatically[^qmkmake].

This matters for packaging the firmware in Nix ([[nix-dev-shell]]). The submodules
would have to be vendored and `SKIP_GIT` set, because the build otherwise calls
git (inferred).

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
git -C .firmware pull
make -C .firmware git-submodule
```

Then rebuild, and check the breaking-changes changelog for keyboard or keycode
renames. After an update, re-pin the study clone and refresh [[qmk-firmware]]
(`commit-hash`).

## Version strings

The firmware embeds both `qmk_firmware`'s version and the userspace's own
`git describe` (`QMK_USERSPACE_VERSION`).

[^cli]: [docs/cli.md](../.repos/qmk_firmware/docs/cli.md), l.18
[^readme]: [README.md](../../README.md)
[^makefile]: [Makefile](../../Makefile)
[^submodule]: [lib/python/qmk/cli/git/submodule.py](../.repos/qmk_firmware/lib/python/qmk/cli/git/submodule.py),
              l.32–37
[^qmkmake]: [Makefile](../.repos/qmk_firmware/Makefile), l.22–29, l.387–391
[^breaking]: [docs/breaking_changes.md](../.repos/qmk_firmware/docs/breaking_changes.md),
             l.3–20
[^observed]: Observed on 2026-10-11: `qmk --version` → 1.2.0,
             `qmk config -ro user.qmk_home` → `None`;
             `~/Library/Application Support/qmk/qmk.ini` contains
             `qmk_home = …/keyboard-config/.firmware`.

---
task-id: 02
blocked-by:
  - 01-flake-package
---

# 02: Lazy `.firmware/` sync from the Makefile

`make ferris/sweep:bdura` on a fresh clone creates `.firmware/` from the pinned
store path and builds incrementally; after a QMK bump it recreates the copy
(`design.md §7`).

## Changes

- `Makefile`
  - Drop the `qmk config user.qmk_home` lookup. Require `QMK_FIRMWARE_SRC` (error
    with a hint to enter the dev shell if unset).
  - `QMK_FIRMWARE_ROOT := $(QMK_USERSPACE)/.firmware`, marker file
    `$(QMK_FIRMWARE_ROOT)/.nix-source`.
  - `sync` target: if the marker does not contain `$(QMK_FIRMWARE_SRC)`, remove
    `.firmware/`, `cp -R` the store path, `chmod -R u+w`, write the marker.
  - The `%:` rule depends on `sync` and forwards to `make -C .firmware` with
    `QMK_USERSPACE` as before. `sync` must not be forwarded.
- `.gitignore`: unchanged (`.firmware/` is already ignored).

## Tests

- `rm -rf .firmware && make ferris/sweep:bdura` builds and leaves
  `ferris_sweep_bdura.hex` in the repo root.
- Second `make ferris/sweep:bdura` does not re-copy (marker unchanged)
  and finishes in a few seconds.
- Changing the marker content and running `make sync` recreates the copy.

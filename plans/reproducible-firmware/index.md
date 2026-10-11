# Reproducible firmware

Package the QMK firmware in the flake so that `nix build` produces a bit-identical
hex from pinned inputs, keep an incremental dev loop on the same pinned source,
and flash through a flake app.

Spec: none; the plan comes from the grill-me session of 2026-10-11.
Design record, cited by section from the task files: [`design.md`](design.md).
Shared background every task needs: [`context.md`](context.md).

Target: branch `main` at `10c3d17`.

## Definition of done

- [x] `nix build .#ferris-sweep-bdura` produces `result/ferris_sweep_bdura.hex`.
- [x] `nix build .#ferris-sweep-bdura --rebuild` succeeds (bit-identical).
- [x] From a deleted `.firmware/`, `make ferris/sweep:bdura` syncs and builds;
  a second run is incremental.
- [x] `nix run .` resolves to the flash app (checked with `--help` or a dry listing,
  no keyboard attached).
- [x] README, `ARCHITECTURE.md` and the wiki describe the new workflow;
  the `lufa` issue is closed.

## Task list

- [x] [`01-flake-package.md`](tasks/01-flake-package.md): pin QMK and the toolchain,
  build packages and apps from `qmk.json`.
- [x] [`02-makefile-sync.md`](tasks/02-makefile-sync.md): lazy `.firmware/` sync
  from the Makefile.
- [x] [`03-docs.md`](tasks/03-docs.md): README, `ARCHITECTURE.md`, wiki, close the
  issue.

## Shape of the dependency graph

```text
01 flake ─┬─> 02 makefile ─> 03 docs
```

Task 02 needs the `QMK_FIRMWARE_SRC` export from task 01. Task 03 documents both.

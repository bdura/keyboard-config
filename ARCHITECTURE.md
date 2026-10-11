# Architecture

A personal QMK configuration for the Ferris Sweep, kept as a QMK external userspace
and built through a Nix flake. The one thing it optimises for is a firmware that
is a pure function of the repository: same lock file, same bytes, on any machine.

## Glossary

- **Userspace** — QMK's mechanism for keeping keymaps outside the firmware tree.
  This repo is one: `qmk.json` marks it, and `keyboards/`, `layouts/` and `users/`
  mirror the firmware's layout.
- **Target** — a `keyboard:keymap` pair, here `ferris/sweep:bdura`. QMK names the
  artefact `ferris_sweep_bdura.hex`.
- **Pinned tree** — the `qmk_firmware` checkout fetched by the flake, with all
  its submodules, at the revision in `flake.lock`.
- **Working copy** — `.firmware/`, a writable, gitignored copy of the pinned tree
  used for incremental builds.

## Bird's Eye View

Two build paths share one source and one compiler:

1. **Release path.** `nix build` runs QMK's `make` inside a sandbox on the
   pinned tree, with this repo overlaid as the userspace and `SKIP_VERSION=yes`
   so no version string or build date enters the hex. The hex is the derivation's
   only output. `nix run .` flashes it.
2. **Iteration path.** The dev shell exports the pinned tree's store path.
   The repo `Makefile` copies it into `.firmware/` when the marker it keeps
   there disagrees with that path, then forwards the goal to QMK's own `make`.
   Make's on-disk cache gives a few-second rebuild after a keymap edit.

The toolchain comes from the stable nixpkgs input, where `qmk` brings an avr-gcc
that QMK upstream supports. Shell-only tools come from the unstable input.

Deliberately out of scope: CI, a two-stage derivation that caches QMK core objects
(the keymap's `config.h` is force-included everywhere, so there is little to
cache), and any keyboard definition. Those live in the firmware tree.

## Entry Point

`flake.nix` reads `build_targets` from `qmk.json` and derives, for each
`[keyboard, keymap]` pair, a package (the hex) and a `flash-*` app. The first pair
is also `packages.default` and `apps.default`. The dev shell is `devShells.default`.

`Makefile` is the entry point for iteration. It refuses to run outside the dev
shell, syncs `.firmware/`, and hands every other goal to `make -C .firmware`.

## Code Map

```text
├── flake.nix                 # Inputs and wiring only; calls into nix/
├── flake.lock                # Pins QMK, both nixpkgs and qmkfmt
├── nix/
│   ├── targets.nix           # qmk.json → list of {keyboard, keymap, env, name, target}
│   ├── userspace.nix         # fileset of what the build may see from this repo
│   ├── firmware.nix          # One target → one derivation whose output is the hex
│   ├── flash.nix             # One firmware package → one `qmk flash` app
│   ├── devshell.nix          # The dev shell; `qmk` from the same nixpkgs as firmware.nix
│   └── qmkfmt.nix            # qmkfmt built from source (not in nixpkgs)
├── qmk.json                  # Userspace manifest; build_targets drives the flake
├── Makefile                  # Lazy .firmware/ sync, then forwards to QMK's make
├── keyboards/ferris/keymaps/bdura/
│   ├── keymap.c              # Layers, combos, home-row mods
│   ├── config.h              # Tap-hold, mouse keys, split settings
│   └── rules.mk              # Feature switches (combos, Caps Word)
├── layouts/, users/          # Empty placeholders kept for QMK's layout
├── prek.toml                 # Pre-commit hooks: builtins, reflow, qmkfmt
├── .clang-format, .clangd    # Editor formatting and LSP flags
└── .firmware/                # Gitignored working copy of the pinned QMK tree
```

### flake.nix and nix/

`flake.nix` declares inputs and instantiates the modules once per system with
`callPackage`, so each module's dependencies are explicit in its argument
set. `targets.nix` and `userspace.nix` are system-independent and evaluated
once. `firmware.nix` holds the only description of how a target is built:
the derivation copies the userspace into a writable directory because QMK copies
the firmware back into it, and points `HOME` at the sandbox's temp dir because
the `qmk` CLI writes config there. The userspace is filtered to `keyboards/`,
`layouts/`, `users/` and `qmk.json`, so documentation edits do not rebuild the
firmware. `flash.nix` reads the hex path from the package's `passthru`, so the app
and the package cannot disagree. The shell module is named `devshell.nix` because
a global git ignore drops any `shell.nix`, and flakes only see tracked files.

### Makefile

The marker file `.firmware/.nix-source` holds the store path the copy was made from.
Any mismatch, including a missing directory, triggers a full re-copy. The copy
is not a git repository, which makes QMK skip its submodule sync on its own.

## Common tasks

- **Change the keymap:** edit under `keyboards/ferris/keymaps/bdura/`,
  run `make ferris/sweep:bdura`, flash with `nix run .` when happy.
- **Add a target:** `qmk userspace-add -kb <kb> -km <km>`, or edit `qmk.json`.
  The flake picks it up with no other change. The first entry is `default`.
- **Change how a target is built:** `nix/firmware.nix`. Check with
  `nix path-info --derivation .#default` whether the derivation changed.
- **Update QMK:** `nix flake update qmk-firmware`, rebuild, check the
  breaking-changes notes for renamed keyboards or keycodes.
- **Update the toolchain:** `nix flake update nixpkgs`. Stay on a release branch
  whose avr-gcc QMK supports; unstable's GCC breaks `-Werror` on QMK core.
- **Check reproducibility:** `nix build --rebuild`.

## Cross-cutting concerns

- **Determinism** is enforced by `SKIP_VERSION=yes` in the derivation and checked
  only by hand with `nix build --rebuild`. Nothing else may read the clock,
  git or the environment during the build.
- **One compiler** for both paths: the dev shell takes `qmk` from the same nixpkgs
  input as the derivation. Pulling it from unstable would silently make the two
  paths diverge.
- **Flash budget.** The Sweep's ATmega32u4 leaves 28672 bytes after the bootloader,
  and the keymap sits at about 95%. Each new feature must be weighed against that.

# Reproducible firmware: shared context

What every task needs to know. Argued in [`design.md`](design.md).

## Facts about QMK's build

- `make <kb>:<km>` at the QMK root runs `qmk git-submodule --sync` unless
  `SKIP_GIT` is set; a tree that is not a git repo sets `SKIP_GIT` itself.
  `SKIP_VERSION=yes` also sets `SKIP_GIT` and makes version strings constant.
- The build invokes the `qmk` CLI (`qmk generate-*`), so `qmk` must be on `PATH`
  in the sandbox. The CLI writes config under `$HOME`; set `HOME` to a temp dir.
- With `QMK_USERSPACE` set, the firmware is copied to both the QMK root and
  `$(QMK_USERSPACE)/<target>.hex`. Both must be writable: copy the userspace into
  the build dir, do not point `QMK_USERSPACE` at the store.
- Objects go to `.build/` under the QMK root; the tree must be writable too
  (stdenv's unpack already copies `src`).
- Target name: `ferris/sweep:bdura` → `ferris_sweep_bdura.hex`, `FIRMWARE_FORMAT`
  is `hex` for AVR.
- AVR needs the `lufa` and `printf` submodules. The flake input fetches all of
  them (`submodules=1`).

## Repo state before the plan

- `flake.nix`: one `nixpkgs` (unstable) input, `qmkfmt-src`; a dev shell only.
- `Makefile`: forwards every goal to `make -C $(qmk config user.qmk_home)`.
- `qmk.json`: `build_targets: []`.
- `README.md`: tells the user to run `qmk setup --home ./.firmware/`.
- `.firmware/` is a gitignored git clone, unpinned.
- No `ARCHITECTURE.md`.

## Verification commands

```shell
nix build .#ferris-sweep-bdura         # produces result/ferris_sweep_bdura.hex
nix build .#ferris-sweep-bdura --rebuild   # fails if the hex is not bit-identical
rm -rf .firmware && make ferris/sweep:bdura   # lazy sync + incremental build
```

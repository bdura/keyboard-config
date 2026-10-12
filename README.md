# QMK configurations

A repo to keep track of my QMK configuration, using [QMK userspace]. The QMK
firmware tree and the toolchain are pinned by `flake.lock`, so `nix build` gives
a bit-identical firmware on any machine.

## Build and flash

```shell
nix build          # result/ferris_sweep_bdura.hex, from pinned inputs
nix run .          # build, then `qmk flash` it; repeat once per half
```

Flashing needs write access to the bootloader's serial port (`/dev/ttyACM*`,
owned by `root:dialout`). Without it, `qmk flash` reports that the Caterina
bootloader "was found but is not writable". On NixOS:

```nix
hardware.keyboard.qmk.enable = true;               # QMK udev rules
users.users.<you>.extraGroups = [ "dialout" ];     # optional, direct port access
```

Rebuild, then replug the keyboard (and log back in if you added `dialout`).

`nix build --rebuild` rebuilds and fails if the output differs from the one already
in the store. It is the check that the firmware is a pure function of `flake.lock`.

## Iterate

The dev shell (`nix develop`, or direnv) exports the pinned QMK tree.
The `Makefile` copies it into the gitignored `.firmware/` on first use and keeps
it in sync with the lock, so QMK's incremental build works:

```shell
make ferris/sweep:bdura                  # syncs .firmware/ if needed, then builds
qmk compile -kb ferris/sweep -km bdura   # same, after a `make sync`
```

The hex lands in the repo root. The dev shell and `nix build` share the same
compiler, so both produce the same bytes.

## Update QMK

```shell
nix flake update qmk-firmware
```

Then rebuild. The next `make` recreates `.firmware/` from the new tree.

[QMK userspace]: https://docs.qmk.fm/newbs_external_userspace

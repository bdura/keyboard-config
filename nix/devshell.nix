# `qmk` must come from the same nixpkgs as `firmware.nix`, so the iteration
# loop and `nix build` share one compiler.
{
  mkShell,
  qmk,
  qmkfmt,
  dos2unix,
  prek,
  qmkFirmware,
}:
mkShell {
  packages = [
    qmk
    qmkfmt
    dos2unix
    prek
  ];

  # Read by the Makefile to populate .firmware/ with the pinned QMK tree.
  QMK_FIRMWARE_SRC = qmkFirmware;

  shellHook = ''
    export QMK_HOME="$PWD/.firmware"
  '';
}

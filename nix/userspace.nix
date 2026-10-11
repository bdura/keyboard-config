# Only what QMK overlays, so README or flake edits do not rebuild the firmware.
{
  lib,
  root,
}:
lib.fileset.toSource {
  inherit root;
  fileset = lib.fileset.unions [
    (root + "/keyboards")
    (root + "/layouts")
    (root + "/users")
    (root + "/qmk.json")
  ];
}

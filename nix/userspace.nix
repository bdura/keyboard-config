# The userspace overlay as seen by the firmware build.
#
# Only the directories QMK overlays, plus the manifest, so that README or flake
# edits do not invalidate the firmware derivation.
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

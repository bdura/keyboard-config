# Build targets, read from the userspace manifest (qmk.json).
#
# Each entry of `build_targets` is `[keyboard, keymap]` or
# `[keyboard, keymap, {env}]` (userspace manifest v1.1), where `env` holds extra
# make variables. Returns one attribute set per target.
{manifest}: let
  json = builtins.fromJSON (builtins.readFile manifest);

  parse = t: rec {
    keyboard = builtins.elemAt t 0;
    keymap = builtins.elemAt t 1;
    env =
      if builtins.length t > 2
      then builtins.elemAt t 2
      else {};
    # Flake attribute name, e.g. `ferris-sweep-bdura`.
    name = "${builtins.replaceStrings ["/"] ["-"] keyboard}-${keymap}";
    # QMK's artefact stem, e.g. `ferris_sweep_bdura`.
    target = "${builtins.replaceStrings ["/"] ["_"] keyboard}_${keymap}";
  };
in
  map parse json.build_targets

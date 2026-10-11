# A flake app that flashes a firmware package built by `firmware.nix`.
#
# Extra arguments are passed to `qmk flash`. Split boards are flashed once per
# half; the Sweep has no EE_HANDS, so both halves take the same hex.
{
  qmk,
  writeShellScript,
}: firmware: {
  type = "app";
  program = toString (writeShellScript "flash-${firmware.passthru.target}" ''
    exec ${qmk}/bin/qmk flash "$@" ${firmware.passthru.firmware}
  '');
  meta.description = "Flash ${firmware.passthru.target} with qmk flash; repeat once per half";
}

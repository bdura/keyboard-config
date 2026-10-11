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

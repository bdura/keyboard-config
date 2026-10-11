{
  lib,
  stdenv,
  qmk,
  qmkFirmware,
  userspace,
}: {
  keyboard,
  keymap,
  target,
  env ? {},
  ...
}: let
  extraVars = lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "${k}=${v}") env);
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "qmk-${target}";
    version = qmkFirmware.shortRev or "dirty";
    src = qmkFirmware;

    nativeBuildInputs = [qmk];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild
      # The qmk CLI writes its config under HOME.
      export HOME="$TMPDIR"
      # QMK copies the firmware into the userspace, so it must be writable.
      cp -R ${userspace} "$TMPDIR/userspace"
      chmod -R u+w "$TMPDIR/userspace"
      # SKIP_VERSION keeps the version string and build date out of the hex.
      make ${keyboard}:${keymap} \
        QMK_USERSPACE="$TMPDIR/userspace" \
        SKIP_VERSION=yes \
        ${extraVars} \
        -j"$NIX_BUILD_CORES"
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp .build/${target}.hex "$out/"
      runHook postInstall
    '';

    passthru = {
      inherit keyboard keymap target;
      firmware = "${finalAttrs.finalPackage}/${target}.hex";
    };

    meta.description = "QMK firmware for ${keyboard}, keymap ${keymap}";
  })

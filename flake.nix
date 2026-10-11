{
  inputs = {
    # Stable channel for the toolchain: `qmk` brings avr-gcc 14, which QMK
    # upstream tests against. Unstable's avr-gcc 16 breaks `-Werror` on QMK core.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # Unstable for shell-only tools, where freshness matters more than stability.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # The QMK tree, with every submodule, pinned by flake.lock.
    # Update with `nix flake update qmk-firmware`.
    qmk-firmware = {
      url = "git+https://github.com/qmk/qmk_firmware?ref=master&submodules=1";
      flake = false;
    };
    qmkfmt-src = {
      url = "github:rcorre/qmkfmt?ref=v0.3.0";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    qmk-firmware,
    qmkfmt-src,
  }: let
    lib = nixpkgs.lib;

    forAllSystems = lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    # Build targets come from qmk.json, the userspace manifest, so that
    # `qmk userspace-add` and the flake agree on what gets built.
    manifest = builtins.fromJSON (builtins.readFile ./qmk.json);
    targets = map (t: {
      keyboard = builtins.elemAt t 0;
      keymap = builtins.elemAt t 1;
      env =
        if builtins.length t > 2
        then builtins.elemAt t 2
        else {};
    }) manifest.build_targets;

    # Only the userspace overlay reaches the build, so README or flake edits
    # do not invalidate the firmware derivation.
    userspace = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./keyboards
        ./layouts
        ./users
        ./qmk.json
      ];
    };

    perSystem = system: let
      pkgs = import nixpkgs {inherit system;};
      unstable = import nixpkgs-unstable {inherit system;};

      qmkfmt = unstable.rustPlatform.buildRustPackage {
        pname = "qmkfmt";
        version = "v0.3.0";
        src = qmkfmt-src;
        cargoHash = "sha256-+0tFSSZR5tBUC0WbJ1Oc3b6n5q3JkaeMnL9bzL6B3zo=";
        doCheck = false;
      };

      slugOf = s: builtins.replaceStrings ["/"] ["-"] s;
      targetOf = {
        keyboard,
        keymap,
        ...
      }: "${builtins.replaceStrings ["/"] ["_"] keyboard}_${keymap}";

      buildFirmware = t @ {
        keyboard,
        keymap,
        env,
      }: let
        target = targetOf t;
        extraVars = lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "${k}=${v}") env);
      in
        pkgs.stdenv.mkDerivation {
          pname = "qmk-${target}";
          version = qmk-firmware.shortRev or "dirty";
          src = qmk-firmware;

          nativeBuildInputs = [pkgs.qmk];

          dontConfigure = true;
          dontFixup = true;

          buildPhase = ''
            runHook preBuild
            # The qmk CLI writes its config under HOME.
            export HOME="$TMPDIR"
            # QMK copies the firmware into the userspace, so it must be writable.
            cp -R ${userspace} "$TMPDIR/userspace"
            chmod -R u+w "$TMPDIR/userspace"
            # SKIP_VERSION makes QMK_VERSION and QMK_BUILDDATE constants, which
            # is what keeps the hex bit-identical across builds.
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

          meta.description = "QMK firmware for ${keyboard}, keymap ${keymap}";
        };

      built = map (t: rec {
        name = "${slugOf t.keyboard}-${t.keymap}";
        target = targetOf t;
        package = buildFirmware t;
        firmware = "${package}/${target}.${package.passthru.format or "hex"}";
      }) targets;

      packages =
        lib.listToAttrs (map (b: lib.nameValuePair b.name b.package) built)
        // lib.optionalAttrs (built != []) {default = (builtins.head built).package;};

      flashApp = b: {
        type = "app";
        program = toString (pkgs.writeShellScript "flash-${b.name}" ''
          exec ${pkgs.qmk}/bin/qmk flash "$@" ${b.firmware}
        '');
        meta.description = "Flash ${b.target} with qmk flash; repeat once per half";
      };

      apps =
        lib.listToAttrs (map (b: lib.nameValuePair "flash-${b.name}" (flashApp b)) built)
        // lib.optionalAttrs (built != []) {default = flashApp (builtins.head built);};

      devShell = pkgs.mkShell {
        packages = [
          pkgs.qmk
          qmkfmt
          unstable.dos2unix
          unstable.prek
        ];

        # Read by the Makefile to populate .firmware/ with the pinned QMK tree.
        QMK_FIRMWARE_SRC = qmk-firmware;

        shellHook = ''
          export QMK_HOME="$PWD/.firmware"
        '';
      };
    in {
      inherit packages apps;
      devShells.default = devShell;
    };

    outputsFor = forAllSystems perSystem;
  in {
    packages = lib.mapAttrs (_: o: o.packages) outputsFor;
    apps = lib.mapAttrs (_: o: o.apps) outputsFor;
    devShells = lib.mapAttrs (_: o: o.devShells) outputsFor;
  };
}

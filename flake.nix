{
  inputs = {
    # Stable for the toolchain: unstable's avr-gcc 16 breaks `-Werror` on QMK core.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
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

    targets = import ./nix/targets.nix {manifest = ./qmk.json;};
    userspace = import ./nix/userspace.nix {
      inherit lib;
      root = ./.;
    };

    perSystem = system: let
      pkgs = import nixpkgs {inherit system;};
      unstable = import nixpkgs-unstable {inherit system;};

      buildFirmware = pkgs.callPackage ./nix/firmware.nix {
        inherit userspace;
        qmkFirmware = qmk-firmware;
      };
      mkFlashApp = pkgs.callPackage ./nix/flash.nix {};
      qmkfmt = unstable.callPackage ./nix/qmkfmt.nix {src = qmkfmt-src;};

      firmwares = map (t: lib.nameValuePair t.name (buildFirmware t)) targets;
      flashApps = map (f: lib.nameValuePair "flash-${f.name}" (mkFlashApp f.value)) firmwares;

      withDefault = pairs:
        lib.listToAttrs pairs
        // lib.optionalAttrs (pairs != []) {default = (builtins.head pairs).value;};
    in {
      packages = withDefault firmwares;
      apps = withDefault flashApps;
      devShells.default = pkgs.callPackage ./nix/devshell.nix {
        inherit qmkfmt;
        inherit (unstable) dos2unix prek;
        qmkFirmware = qmk-firmware;
      };
    };

    outputsFor = forAllSystems perSystem;
  in {
    packages = lib.mapAttrs (_: o: o.packages) outputsFor;
    apps = lib.mapAttrs (_: o: o.apps) outputsFor;
    devShells = lib.mapAttrs (_: o: o.devShells) outputsFor;
  };
}

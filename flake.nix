{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    qmkfmt-src = {
      url = "github:rcorre/qmkfmt?ref=v0.3.0";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    qmkfmt-src,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in {
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        qmkfmt = pkgs.rustPlatform.buildRustPackage {
          pname = "qmkfmt";
          version = "v0.3.0";
          src = qmkfmt-src;
          cargoHash = "sha256-+0tFSSZR5tBUC0WbJ1Oc3b6n5q3JkaeMnL9bzL6B3zo=";
          doCheck = false;
        };
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            qmk
            qmkfmt

            dos2unix

            prek
          ];
        };
      }
    );
  };
}

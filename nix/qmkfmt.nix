# qmkfmt is not in nixpkgs; build it from the pinned source.
{
  rustPlatform,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "qmkfmt";
  version = "v0.3.0";
  inherit src;
  cargoHash = "sha256-+0tFSSZR5tBUC0WbJ1Oc3b6n5q3JkaeMnL9bzL6B3zo=";
  doCheck = false;
}

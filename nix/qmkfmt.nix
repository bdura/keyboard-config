# Not in nixpkgs.
{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "qmkfmt";
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "rcorre";
    repo = "qmkfmt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-X2vXQqBUO+4H+sF+Tak6ksTE9Jv3o56fPImJhdH5x40=";
  };
  cargoHash = "sha256-+0tFSSZR5tBUC0WbJ1Oc3b6n5q3JkaeMnL9bzL6B3zo=";
  doCheck = false;
})

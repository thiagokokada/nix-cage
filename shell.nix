{ pkgs ? import ./nixpkgs.nix { }, ... }:

with pkgs;

stdenv.mkDerivation {
  name = "nix-shell";
  buildInputs = [
    gnumake
    bashInteractive
    python3
    jq
  ];
}

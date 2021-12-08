{
  description = "nix-alien";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, flake-utils, nixpkgs }:
    {
      overlay = (final: prev: {
        nix-cage = prev.callPackage ./default.nix { };
      });
    } //
    flake-utils.lib.eachSystem [ "aarch64-linux" "i686-linux" "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
      in
      {
        defaultPackage = self.packages.${system}.nix-cage;

        packages = {
          inherit (pkgs) nix-cage;
        };
      });
}

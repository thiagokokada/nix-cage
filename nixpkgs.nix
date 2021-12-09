# Compatibility with non-flakes systems
let
  flakeLock = (builtins.fromJSON (builtins.readFile ./flake.lock));
  inherit (flakeLock.nodes.nixpkgs.locked) rev narHash;
  nixpkgsTarball = (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    sha256 = narHash;
  });
in
import nixpkgsTarball 

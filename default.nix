{ pkgs ? import ./nixpkgs.nix { }, ... }:

with pkgs;

python3.pkgs.buildPythonApplication rec {
  name = "nix-cage";
  src = ./.;

  buildInputs = [ bubblewrap nix ];

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ bubblewrap nix ]}"
  ];

  meta = {
    homepage = https://github.com/thiagokokada/nix-cage;
    description = "Sandboxed environments with nix-shell";
    longDescription = ''
      Sandboxed environments with bwrap and nix-shell
    '';
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}

{ pkgs ? import <nixpkgs> { }, ... }:

with pkgs;

stdenv.mkDerivation rec {
  name = "nix-cage";
  buildInputs = [ python3 bubblewrap nix ];
  nativeBuildInputs = [ makeWrapper ];
  src = ./.;

  buildPhase = ''
    patchShebangs .
  '';

  installPhase = ''
    source $stdenv/setup
    set -e

    mkdir -p $out/bin
    cp       $src/${name} $out/bin
    chmod +x $out/bin/${name}

    wrapProgram $out/bin/${name} --prefix PATH : ${lib.makeBinPath [
      bubblewrap
      nix
    ]}
  '';

  meta = {
    homepage = https://github.com/corpix/nix-cage;
    description = "Sandboxed environments with nix-shell";

    longDescription = ''
      Sandboxed environments with bwrap and nix-shell
    '';

    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}

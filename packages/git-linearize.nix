{ nixpkgs, system, ... }:

let
  pkgs = import nixpkgs { inherit system; };
  version = "main";
in
pkgs.stdenv.mkDerivation {
  pname = "git-linearize";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "zegl";
    repo = "extremely-linear";
    rev = version;
    sha256 = "sha256-aZGxX4B0hUrYWxViFAjbZ4dCWC2ujEBAlBKdx408KhA=";
  };

  propagatedBuildInputs = [ pkgs.lucky-commit ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/git-linearize $src/shit $out/bin/
  '';
}

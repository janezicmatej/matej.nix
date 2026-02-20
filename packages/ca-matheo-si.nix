{ nixpkgs, system, ... }:

let
  pkgs = import nixpkgs { inherit system; };
  version = "C6r62em";
in

pkgs.stdenv.mkDerivation {
  pname = "ca-matheo-si";
  version = version;

  src = pkgs.fetchurl {
    url = "http://ipa2.matheo.si/ipa/config/ca.crt";
    sha256 = "sha256-C6r62emPyw1kxUZOTWhwABNyBEWTTLMEVX5Ma/2i9ls";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/ca-matheo-si.cert
  '';
}

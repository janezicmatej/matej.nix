{ nixpkgs-master, system, ... }:

let
  nixpkgs = nixpkgs-master;
  pkgs = import nixpkgs { inherit system; };
  version = "v1.25.0";
  python = pkgs.python313;
in

python.pkgs.buildPythonPackage rec {
  pname = "releasectl";
  version = "1.2.0";

  src = pkgs.fetchurl {
    url = "https://gitlab.com/flarenetwork/infra-public/pipeliner/-/package_files/216813866/download";
    sha256 = "sha256-ScBG8BoOKDdOAHTFP+zwyk+Kfu31WoKQSRkutOvnJ5E";
  };

  format = "wheel";
  # nativeBuildInputs = [ python.pkgs.setuptools python.pkgs.wheel ];
  # propagatedBuildInputs = with python.pkgs; [
  #   # add runtime deps here if needed
  # ];

  # pyproject = true;
  # build-system =  [ pkgs.python313Packages.hatchling ];

}

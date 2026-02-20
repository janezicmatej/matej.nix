{ nixpkgs-master, system, ... }:

let
  nixpkgs = nixpkgs-master;
  pkgs = import nixpkgs { inherit system; };
  version = "e24855c";
in
pkgs.buildGoModule.override
  {
    go = pkgs.go_1_26;
  }
  {
    pname = "ggman";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "tkw1536";
      repo = "ggman";
      rev = version;
      sha256 = "sha256-H78xtF7l5joX3/qDFaRIT4LyZpHmm6DMR4JIKzNO7c0=";
    };

    vendorHash = "sha256-w8NrOt0xtn+/gugJ4amzdJP70Y5KHe5DlhsEprycm3U=";
    subPackages = [ "cmd/ggman" ];

    ldflags = [
      "-X go.tkw01536.de/ggman.buildVersion=${version}"
    ];

    meta = {
      description = "Manager for all your local git repositories";
      homepage = "https://github.com/tkw1536/ggman";
      license = pkgs.lib.licenses.mit;
      maintainers = [ ];
    };
  }

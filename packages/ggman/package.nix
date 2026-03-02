{ pkgs-master, ... }:

let
  pkgs = pkgs-master;
  version = "v1.27.1";
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
      sha256 = "sha256-z7zqV69rPYwtkm4ieF+FIssBsFbREvaYQzSF648DHK0=";
    };

    vendorHash = "sha256-5c5EgYjZXfexWMrUDS4fo46GCJBmFuWkw0cVqqGT7Ik=";
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

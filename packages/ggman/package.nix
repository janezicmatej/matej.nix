{ pkgs-master, ... }:

let
  pkgs = pkgs-master;
  version = "v1.28.0";
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
      sha256 = "sha256-xj5sJ8k63GNvYWdJ4huyHU9qzPxzR4fZjAHwZrQtiFQ=";
    };

    vendorHash = "sha256-NNQ89X8GsMAA/4EvLBJVZRsBBQtfFzGRTRAbX/eRmvI=";
    subPackages = [ "cmd/ggman" ];

    ldflags = [
      "-X go.tkw01536.de/ggman.buildVersion=${version}"
    ];

    nativeBuildInputs = [ pkgs.installShellFiles ];

    postInstall = ''
      installShellCompletion --cmd ggman \
        --bash <($out/bin/ggman completion bash) \
        --zsh <($out/bin/ggman completion zsh) \
        --fish <($out/bin/ggman completion fish)
    '';

    meta = {
      description = "Manager for all your local git repositories";
      homepage = "https://github.com/tkw1536/ggman";
      license = pkgs.lib.licenses.mit;
      maintainers = [ ];
    };
  }

{ pkgs, ... }:

let
  version = "v0.4.2";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "ahab";
  inherit version;

  src = pkgs.fetchFromGitea {
    domain = "git.janezic.dev";
    owner = "janezicmatej";
    repo = "ahab";
    rev = version;
    sha256 = "sha256-hJg6vRaqTu9a3fua2J/e6akdJQffAk6TBAzJRBD5qHQ=";
  };

  cargoHash = "sha256-T/2+kxa5X2fmMQs023JN9ZDihExfYvPnunJ8b2Irwoo=";

  buildType = "debug";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  preBuild = ''
    mkdir -p completions
  '';

  SHELL_COMPLETIONS_DIR = "completions";

  postInstall = ''
    installShellCompletion --bash completions/ahab.bash
    installShellCompletion --zsh completions/_ahab
    installShellCompletion --fish completions/ahab.fish
  '';

  meta = {
    description = "ahab";
    homepage = "https://git.janezic.dev/janezicmatej/ahab";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
  };
}

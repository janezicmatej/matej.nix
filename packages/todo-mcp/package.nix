{ pkgs, ... }:

let
  version = "v0.3.1";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "todo-mcp";
  inherit version;

  src = pkgs.fetchFromGitea {
    domain = "git.janezic.dev";
    owner = "janezicmatej";
    repo = "todo-mcp";
    rev = version;
    sha256 = "sha256-FLsPatHeWcDMLaGZS91aaXtZEful5frN2pqZkQN9vNs=";
  };

  cargoHash = "sha256-gdR4p5LIEMGBV3ikuuRZ5R8CYIjE1K2OnMJm7yo18Nw=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  preBuild = ''
    mkdir -p completions
  '';

  SHELL_COMPLETIONS_DIR = "completions";

  postInstall = ''
    installShellCompletion --bash completions/todo-mcp.bash
    installShellCompletion --zsh completions/_todo-mcp
    installShellCompletion --fish completions/todo-mcp.fish
  '';

  meta = {
    description = "simple todo cli with mcp server for ai integration";
    homepage = "https://git.janezic.dev/janezicmatej/todo-mcp";
    maintainers = [ ];
  };
}

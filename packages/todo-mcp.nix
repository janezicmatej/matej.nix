{ pkgs, ... }:

let
  version = "v0.2.1";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "todo-mcp";
  inherit version;

  src = pkgs.fetchFromGitea {
    domain = "git.janezic.dev";
    owner = "janezicmatej";
    repo = "todo-mcp";
    rev = version;
    sha256 = "sha256-BBL7PAgTdGR/+vEJmot8c8mgw5vq5Y/szud0YEiR1UY=";
  };

  cargoHash = "sha256-uAyD7Tj9qctDXQ5NkR6T/aItxRmd5WqIXr7NeOlCl8M=";

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

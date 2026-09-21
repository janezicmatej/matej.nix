{ pkgs, ... }:

let
  version = "v0.6.0";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "ahab";
  inherit version;

  src = pkgs.fetchFromGitea {
    domain = "git.janezic.dev";
    owner = "janezicmatej";
    repo = "ahab";
    rev = version;
    sha256 = "sha256-vklDPlYP4Du7e1YbhgIkyvzo15qNP1WYFY3YNA3hC4Q=";
  };

  cargoHash = "sha256-UfwO50la1F7Jimsk9s5Rwc66yfhatEaia5sX47oIGLI=";

  buildType = "debug";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  # NOTE:(@janezicmatej) integration tests shell out to git
  nativeCheckInputs = [ pkgs.git ];

  # NOTE:(@janezicmatej) build.rs rejects a relative completions dir since v0.5.0
  preBuild = ''
    export SHELL_COMPLETIONS_DIR="$NIX_BUILD_TOP/completions"
    mkdir -p "$SHELL_COMPLETIONS_DIR"
  '';

  postInstall = ''
    installShellCompletion --bash "$NIX_BUILD_TOP/completions/ahab.bash"
    installShellCompletion --zsh "$NIX_BUILD_TOP/completions/_ahab"
    installShellCompletion --fish "$NIX_BUILD_TOP/completions/ahab.fish"
  '';

  meta = {
    description = "ahab";
    homepage = "https://git.janezic.dev/janezicmatej/ahab";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
  };
}

{ pkgs, ... }:

let
  version = "v0.5.0";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "ahab";
  inherit version;

  src = pkgs.fetchFromGitea {
    domain = "git.janezic.dev";
    owner = "janezicmatej";
    repo = "ahab";
    rev = version;
    sha256 = "sha256-Fy1T95OA4RwMLJF1EP0hGlgrVFl8C0P66YGeOPWspSU=";
  };

  cargoHash = "sha256-PeZPQY9OGGQ1R+mSRgOvZxdcFpgqV12wAxmHiDLZyf8=";

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

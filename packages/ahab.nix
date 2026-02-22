{ pkgs, ... }:

let
  version = "v0.3.2";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "ahab";
  inherit version;

  src = pkgs.fetchFromGitea {
    domain = "git.janezic.dev";
    owner = "janezicmatej";
    repo = "ahab";
    rev = version;
    sha256 = "sha256-bL8LPpD5k97XPYftXhPr7V/LNOB71pcBlsfBjJUIeG8";
  };

  cargoHash = "sha256-f8omNtjLF5gMJGgxdzWifStcs8d4fu++EegR2auObXE";

  buildType = "debug";

  meta = {
    description = "ahab";
    homepage = "https://git.janezic.dev/janezicmatej/ahab";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
  };
}

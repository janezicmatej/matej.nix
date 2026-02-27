{ pkgs, ... }:

let
  version = "v0.4.1";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "ahab";
  inherit version;

  src = pkgs.fetchFromGitea {
    domain = "git.janezic.dev";
    owner = "janezicmatej";
    repo = "ahab";
    rev = version;
    sha256 = "sha256-Y8UqZOskSlt8GrYem97yKXNbGkd6Ab7WRynKEA9w16E=";
  };

  cargoHash = "sha256-T5r+Og3+mHMsqCFGi+QzHdN2MgvPxzA/R+xu38I+lcg=";

  buildType = "debug";

  meta = {
    description = "ahab";
    homepage = "https://git.janezic.dev/janezicmatej/ahab";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
  };
}

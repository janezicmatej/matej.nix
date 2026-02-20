{ lib }:

let
  mkHost = import ./mkHost.nix;
  autoDir = import ./autoDir.nix lib;
  mapDir = import ./mapDir.nix lib;
in

{
  inherit mkHost autoDir mapDir;
}

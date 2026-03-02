lib:

# import package.nix from each subdirectory in dir as attribute set
dir:
let
  readDir = builtins.readDir dir;
  dirs = lib.attrNames (lib.filterAttrs (_: type: type == "directory") readDir);
  packages = lib.filter (name: builtins.pathExists (dir + "/${name}/package.nix")) dirs;
in
lib.genAttrs packages (name: import (dir + "/${name}/package.nix"))

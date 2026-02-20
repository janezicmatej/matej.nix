lib:

# takes dir as an argument and creates an attribute set by importing all .nix files in that directory
dir:
let
  readDir = builtins.readDir dir;
  files = lib.attrNames (
    lib.filterAttrs (
      name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
    ) readDir
  );

  packages = builtins.map (name: lib.removeSuffix ".nix" name) files;
in
lib.genAttrs packages (name: import (dir + "/${name}.nix"))

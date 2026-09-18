{ inputs, ... }:

{
  flake.overlays.default =
    final: prev:
    let
      # WARN:(@janezicmatej) attribute names must not depend on `final` or the fixpoint recurses
      inherit (prev) lib;
      inherit (final.stdenv.hostPlatform) system;

      pinned = {
        nixpkgs-stable = {
          mcp-nixos = null;
          rocketchat-desktop = "sso login in the server webview is broken since 4.16.0";
        };
        nixpkgs-master = { };
      };

      version = pkg: pkg.version or (lib.getVersion pkg);

      pinFrom =
        channel: pins:
        builtins.mapAttrs (
          name: reason:
          let
            pkg = inputs.${channel}.legacyPackages.${system}.${name};
          in
          lib.warn (
            "overlay: ${name} pinned to ${channel} ${version pkg} (nixpkgs has ${version prev.${name}})"
            + lib.optionalString (reason != null) ": ${reason}"
          ) pkg
        ) pins;
    in
    lib.concatMapAttrs pinFrom pinned;
}

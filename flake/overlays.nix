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
        };
        nixpkgs-master = { };
      };

      overrides = {
        # nixpkgs writes `Exec=rocketchat-desktop` without a field code. glib-based
        # launchers (xdg-desktop-portal OpenURI, which chrome prefers) then fall back
        # to %f and drop non-file uris, so the rocketchat://auth deeplink that
        # completes browser sso never reaches the running app
        # TODO:(@janezicmatej) drop once nixpkgs adds %U to the desktop entry
        rocketchat-desktop = prev.rocketchat-desktop.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            substituteInPlace $out/share/applications/rocketchat-desktop.desktop \
              --replace-fail 'Exec=rocketchat-desktop' 'Exec=rocketchat-desktop %U'
          '';
        });
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
    lib.concatMapAttrs pinFrom pinned // overrides;
}

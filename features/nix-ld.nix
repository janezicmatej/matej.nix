{
  nixos =
    { config, lib, ... }:
    let
      cfg = config.features.nix-ld;
    in
    {
      options.features.nix-ld.enable = lib.mkEnableOption "nix-ld";

      config = lib.mkIf cfg.enable {
        programs.nix-ld.enable = true;
      };
    };
}

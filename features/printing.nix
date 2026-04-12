{
  nixos =
    { config, lib, ... }:
    let
      cfg = config.features.printing;
    in
    {
      options.features.printing.enable = lib.mkEnableOption "printing";

      config = lib.mkIf cfg.enable {
        services.printing.enable = true;
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
      };
    };
}

{
  nixos =
    { lib, config, ... }:
    let
      cfg = config.features.localisation;
    in
    {
      options.features.localisation = {
        enable = lib.mkEnableOption "localisation";

        timeZone = lib.mkOption {
          type = lib.types.str;
          default = "Europe/Ljubljana";
        };

        defaultLocale = lib.mkOption {
          type = lib.types.str;
          default = "en_US.UTF-8";
        };
      };

      config = lib.mkIf cfg.enable {
        time.timeZone = cfg.timeZone;
        i18n.defaultLocale = cfg.defaultLocale;

        # NOTE:(@janezicmatej) some apps (e.g. java) need TZ env var explicitly
        environment.variables.TZ = cfg.timeZone;
      };
    };
}

{
  nixos =
    { config, lib, ... }:
    let
      cfg = config.features.power;
    in
    {
      options.features.power = {
        enable = lib.mkEnableOption "laptop power management";

        resumeDevice = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };

        lidSwitch = lib.mkOption {
          type = lib.types.str;
          default = "suspend-then-hibernate";
        };

        powerKey = lib.mkOption {
          type = lib.types.str;
          default = "suspend-then-hibernate";
        };

        idleAction = lib.mkOption {
          type = lib.types.str;
          default = "suspend-then-hibernate";
        };

        idleActionSec = lib.mkOption {
          type = lib.types.str;
          default = "15min";
        };

        hibernateDelaySec = lib.mkOption {
          type = lib.types.str;
          default = "30min";
        };
      };

      config = lib.mkIf cfg.enable {
        boot.resumeDevice = lib.mkIf (cfg.resumeDevice != null) cfg.resumeDevice;

        services.logind.settings.Login = {
          HandleLidSwitch = cfg.lidSwitch;
          HandlePowerKey = cfg.powerKey;
          IdleAction = cfg.idleAction;
          IdleActionSec = cfg.idleActionSec;
        };

        systemd.sleep.settings.Sleep = {
          HibernateDelaySec = cfg.hibernateDelaySec;
        };
      };
    };
}

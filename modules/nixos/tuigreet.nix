{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    tuigreet = {
      enable = lib.mkEnableOption "greetd with tuigreet";

      command = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf config.tuigreet.enable {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session = {
          command = pkgs.writeShellScript "tuigreet-session" ''
            ${pkgs.util-linux}/bin/setterm --blank 1 --powersave powerdown --powerdown 1
            exec ${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.tuigreet.command}
          '';
          user = "greeter";
        };
      };
    };
  };
}

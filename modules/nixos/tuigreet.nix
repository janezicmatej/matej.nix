{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.tuigreet;
in
{
  options = {
    tuigreet = {
      enable = lib.mkEnableOption "greetd with tuigreet";

      command = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session = {
          command = builtins.toString (
            pkgs.writeShellScript "tuigreet-session" ''
              ${pkgs.util-linux}/bin/setterm --blank 1 --powersave powerdown --powerdown 1
              exec ${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${cfg.command}
            ''
          );
          user = "greeter";
        };
      };
    };
  };
}

{
  nixos =
    {
      config,
      lib,
      user,
      ...
    }:
    let
      cfg = config.features.onepassword;
    in
    {
      options.features.onepassword.enable = lib.mkEnableOption "1password";

      config = lib.mkIf cfg.enable {
        programs._1password.enable = true;
        programs._1password-gui = {
          enable = true;
          polkitPolicyOwners = [ user ];
        };
      };
    };
}

{
  nixos =
    {
      config,
      lib,
      pkgs,
      user,
      ...
    }:
    let
      cfg = config.features.networkmanager;
    in
    {
      options.features.networkmanager.enable = lib.mkEnableOption "networkmanager";

      config = lib.mkIf cfg.enable {
        networking.networkmanager.enable = true;
        networking.nameservers = [
          "1.1.1.1"
          "8.8.8.8"
        ];

        users.users.${user}.extraGroups = [ "networkmanager" ];

        # nm-connection-editor handles wpa-enterprise where nmtui cannot
        environment.systemPackages = [ pkgs.networkmanagerapplet ];
      };
    };
}

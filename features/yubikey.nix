{
  nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        yubikey-personalization
        yubikey-manager
      ];

      services.pcscd.enable = true;
    };
}

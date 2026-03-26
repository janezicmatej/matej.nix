{
  nixos =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options = {
        vm-guest.headless = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };

      config = {
        services.qemuGuest.enable = true;
        services.spice-vdagentd.enable = lib.mkIf (!config.vm-guest.headless) true;

        boot.kernelParams = lib.mkIf config.vm-guest.headless [ "console=ttyS0,115200" ];

        boot.initrd.availableKernelModules = [
          "9p"
          "9pnet_virtio"
        ];
        boot.kernelModules = [
          "9p"
          "9pnet_virtio"
        ];

        networking = {
          useDHCP = true;
          firewall.allowedTCPPorts = [ 22 ];
        };

        security.sudo.wheelNeedsPassword = false;

        environment.systemPackages = with pkgs; [
          curl
          wget
          htop
          sshfs
        ];
      };
    };
}

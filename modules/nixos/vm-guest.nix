{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    vm-guest = {
      enable = lib.mkEnableOption "VM guest configuration";
      headless = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "run without display, serial console only";
      };
    };
  };

  config = lib.mkIf config.vm-guest.enable {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = lib.mkIf (!config.vm-guest.headless) true;

    boot.kernelParams = lib.mkIf config.vm-guest.headless [ "console=ttyS0,115200" ];

    # 9p for host file mounting
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
}

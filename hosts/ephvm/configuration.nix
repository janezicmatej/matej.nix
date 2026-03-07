{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  networking.hostName = "ephvm";

  profiles.base.enable = true;

  vm-guest = {
    enable = true;
    headless = true;
  };

  vm-9p-automount = {
    enable = true;
    user = "matej";
  };

  localisation = {
    timeZone = "UTC";
    defaultLocale = "en_US.UTF-8";
  };

  virtualisation.docker = {
    enable = true;
    logDriver = "json-file";
  };

  # TODO:(@janezicmatej) move neovim dotfiles wiring to a cleaner place
  home-manager.users.matej = {
    neovim.dotfiles = inputs.nvim;
  };

  # writable claude config via 9p
  fileSystems."/home/matej/.claude" = {
    device = "claude";
    fsType = "9p";
    options = [
      "trans=virtio"
      "version=9p2000.L"
      "nofail"
      "x-systemd.automount"
    ];
  };

  # .claude.json passed via qemu fw_cfg
  boot.kernelModules = [ "qemu_fw_cfg" ];
  systemd.services.claude-json = {
    after = [ "systemd-modules-load.service" ];
    wants = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "claude-json" ''
        src="/sys/firmware/qemu_fw_cfg/by_name/opt/claude.json/raw"
        [ -f "$src" ] || exit 0
        cp "$src" /home/matej/.claude.json
        chown matej:users /home/matej/.claude.json
      '';
    };
  };

  system.stateVersion = "25.11";
}

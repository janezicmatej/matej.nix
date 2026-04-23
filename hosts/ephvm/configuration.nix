{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  features.nix-settings.towerCache.enable = false;
  # no hardware firmware needed in a VM
  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.wirelessRegulatoryDatabase = lib.mkForce false;

  documentation.enable = false;
  environment.defaultPackages = [ ];

  # qcow2, no channel copy; post-processed with parallel zstd on qcow2 v3
  # (~half the size of zlib v2, faster decompress)
  image.modules.qemu =
    { config, modulesPath, ... }:
    {
      system.build.image = lib.mkForce (
        let
          rawImage = import (modulesPath + "/../lib/make-disk-image.nix") {
            inherit lib config pkgs;
            inherit (config.virtualisation) diskSize;
            inherit (config.image) baseName;
            format = "qcow2";
            copyChannel = false;
            partitionTableType = "legacy";
          };
          inherit (config.image) baseName;
        in
        pkgs.runCommand baseName { nativeBuildInputs = [ pkgs.qemu-utils ]; } ''
          mkdir -p $out
          # qemu-img caps -m at 16
          cores="''${NIX_BUILD_CORES:-4}"
          [ "$cores" -gt 0 ] || cores=4
          [ "$cores" -gt 16 ] && cores=16
          qemu-img convert \
            -f qcow2 \
            -O qcow2 \
            -c \
            -o compression_type=zstd \
            -m "$cores" \
            ${rawImage}/${baseName}.qcow2 \
            $out/${baseName}.qcow2
        ''
      );
    };

  # auto-login on serial console
  services.getty.autologinUser = "matej";

  # enable zsh in home-manager so starship init gets wired up
  home-manager.users.matej.programs.zsh = {
    enable = true;
    dotDir = "/home/matej/.config/zsh";
    shellAliases.dsp = "claude --dangerously-skip-permissions";
  };

  home-manager.users.matej.programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$username$hostname$directory$character";
      hostname = {
        ssh_only = false;
        style = "bold blue";
        format = "[@$hostname]($style)";
      };
      username = {
        show_always = true;
        style_user = "bold blue";
        format = "[$user]($style)";
      };
      directory.format = " [$path]($style) ";
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
    };
  };

  features.vm-guest.headless = true;
  features.vm-guest.automount = {
    enable = true;
    user = "matej";
  };
  features.neovim.dotfiles = inputs.nvim;

  # ensure .config exists with correct ownership before automount
  systemd.tmpfiles.rules = [ "d /home/matej/.config 0700 matej users -" ];

  # TODO:(@janezicmatej) replace ssh with virtio-console (hvc0) when qemu 11.0 lands
  # https://www.mail-archive.com/qemu-devel@nongnu.org/msg1162844.html
  # accept any ssh key (ephemeral localhost-only vm)
  services.openssh.settings.AuthorizedKeysCommand =
    let
      acceptKey = pkgs.writeShellScript "ephvm-accept-key" ''echo "$1 $2"'';
    in
    "${acceptKey} %t %k";
  services.openssh.settings.AuthorizedKeysCommandUser = "nobody";

  # writable claude config via 9p
  fileSystems."/home/matej/.config/claude" = {
    device = "claude";
    fsType = "9p";
    options = [
      "trans=virtio"
      "version=9p2000.L"
      "nofail"
      "x-systemd.automount"
    ];
  };

  environment.sessionVariables.CLAUDE_CONFIG_DIR = "/home/matej/.config/claude";

  system.stateVersion = "25.11";
}

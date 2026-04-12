{
  nixos =
    { config, lib, userKeys, ... }:
    let
      cfg = config.features.filedrop;
    in
    {
      options.features.filedrop = {
        enable = lib.mkEnableOption "filedrop sftp service";

        sopsFile = lib.mkOption {
          type = lib.types.path;

        };
      };

      config = lib.mkIf cfg.enable {
        sops.secrets.filedrop-authorized-keys = {
          inherit (cfg) sopsFile;
          mode = "0444";
        };

        users.groups.filedrop = {
          members = [ "matej" ];
        };

        users.users.filedrop = {
          isSystemUser = true;
          group = "filedrop";
          home = "/home/filedrop";
          shell = "/run/current-system/sw/bin/nologin";
          openssh.authorizedKeys.keys = userKeys.sshAuthorizedKeys;
        };

        # chroot dir must be root-owned; incoming is writable by filedrop
        systemd.tmpfiles.rules = [
          "d /home/filedrop 0755 root root -"
          "d /home/filedrop/incoming 2775 filedrop filedrop -"
          "a+ /home/filedrop/incoming - - - - group:filedrop:rwx"
          "a+ /home/filedrop/incoming - - - - default:group:filedrop:rwx"
          "a+ /home/filedrop/incoming - - - - default:mask::rwx"
          "L /home/matej/filedrop - - - - /home/filedrop/incoming"
        ];

        # relaxed umask so default acl takes full effect
        services.openssh.extraConfig = ''
          Match User filedrop
            ForceCommand internal-sftp -u 0002
            ChrootDirectory /home/filedrop
            AuthorizedKeysFile /etc/ssh/authorized_keys.d/filedrop %h/.ssh/authorized_keys ${config.sops.secrets.filedrop-authorized-keys.path}
            AllowTcpForwarding no
            X11Forwarding no
        '';
      };
    };
}

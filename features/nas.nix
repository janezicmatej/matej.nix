{
  nixos =
    {
      config,
      lib,
      user,
      ...
    }:
    let
      cfg = config.features.nas;
      owner = config.users.users.${user};
      # magicdns name, so the mount works both at home and away
      host = "zeus.magic.headscale";
    in
    {
      options.features.nas.enable = lib.mkEnableOption "samba shares from zeus, automounted over the tailnet";

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = config.services.tailscale.enable;
            message = "features.nas reaches zeus over the tailnet and needs features.tailscale";
          }
        ];

        sops.secrets.nas-password.sopsFile = ../secrets/nas.yaml;

        # rendered to /run/secrets, root-only; keeps the password out of the store
        sops.templates.nas-credentials.content = ''
          username=gorazd
          password=${config.sops.placeholder.nas-password}
        '';

        fileSystems = lib.genAttrs' [ "private" "shared" ] (
          share:
          lib.nameValuePair "/mnt/nas/${share}" {
            device = "//${host}/${share}";
            fsType = "cifs";
            options = [
              "x-systemd.automount"
              "nofail"
              "x-systemd.idle-timeout=300"
              "x-systemd.mount-timeout=5s"
              # magicdns only resolves once tailscaled is up
              "x-systemd.after=tailscaled.service"
              "credentials=${config.sops.templates.nas-credentials.path}"
              "uid=${toString owner.uid}"
              "gid=${toString config.users.groups.${owner.group}.gid}"
            ];
          }
        );
      };
    };
}

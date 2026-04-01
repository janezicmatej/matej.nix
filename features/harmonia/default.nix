{
  nixos =
    {
      pkgs,
      config,
      inputs,
      ...
    }:
    let
      hosts = [
        "fw16"
        "tower"
        "cube"
        "floo"
        "ephvm"
      ];
      flakeRef = inputs.self.outPath;
    in
    {
      services.harmonia = {
        enable = true;
        signKeyPaths = [ config.sops.secrets.nix-signing-key.path ];
      };

      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 5000 ];

      systemd.services.cache-builder = {
        description = "Build all host closures for binary cache";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash ${./cache-builder.sh}";
        };
        environment = {
          FLAKE_REF = flakeRef;
          HOSTS = builtins.concatStringsSep " " hosts;
          GC_ROOT_DIR = "/nix/var/nix/gcroots/cache-builder";
        };
        path = [ config.nix.package ];
      };

      systemd.timers.cache-builder = {
        description = "Periodically build all host closures";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnUnitActiveSec = "15min";
          OnBootSec = "5min";
          Persistent = true;
        };
      };
    };
}

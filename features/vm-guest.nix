{
  nixos =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.features.vm-guest;
      autoUser = cfg.automount.user;
      autoHome = config.users.users.${autoUser}.home;
      autoGroup = config.users.users.${autoUser}.group;
    in
    {
      options.features.vm-guest = {
        enable = lib.mkEnableOption "qemu vm guest";

        headless = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        automount = {
          enable = lib.mkEnableOption "9p share automount";

          user = lib.mkOption {
            type = lib.types.str;
          };

          prefix = lib.mkOption {
            type = lib.types.str;
            default = "m_";
          };

          basePath = lib.mkOption {
            type = lib.types.str;
            default = "${autoHome}/mnt";
          };
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            services.spice-vdagentd.enable = lib.mkIf (!cfg.headless) true;

            boot.kernelParams = lib.mkIf cfg.headless [ "console=ttyS0,115200" ];

            # 9p autoloads on first mount
            boot.initrd.availableKernelModules = [
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
            ];
          }

          (lib.mkIf cfg.automount.enable {
            systemd.services.vm-9p-automount = {
              description = "Auto-discover and mount 9p shares";
              after = [
                "local-fs.target"
                "nss-user-lookup.target"
                "systemd-modules-load.service"
              ];
              wants = [ "systemd-modules-load.service" ];
              wantedBy = [ "multi-user.target" ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = pkgs.writeShellScript "vm-9p-automount" ''
                  BASE="${cfg.automount.basePath}"
                  PREFIX="${cfg.automount.prefix}"
                  mkdir -p "$BASE"
                  chown ${autoUser}:${autoGroup} "$BASE"

                  for tagfile in $(find /sys/devices -name mount_tag 2>/dev/null); do
                    [ -f "$tagfile" ] || continue
                    tag=$(tr -d '\0' < "$tagfile")

                    case "$tag" in
                      "$PREFIX"*) ;;
                      *) continue ;;
                    esac

                    name="''${tag#"$PREFIX"}"
                    target="$BASE/$name"

                    mkdir -p "$target"
                    ${pkgs.util-linux}/bin/mount -t 9p "$tag" "$target" \
                      -o trans=virtio,version=9p2000.L || continue
                  done
                '';
              };
            };
          })
        ]
      );
    };
}

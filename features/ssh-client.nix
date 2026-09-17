{
  nixos =
    {
      lib,
      config,
      user,
      ...
    }:
    let
      cfg = config.features.ssh-client;
    in
    {
      options.features.ssh-client = {
        enable = lib.mkEnableOption "ssh client with sops-managed private host fragments";

        fragments = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options.sopsFile = lib.mkOption {
                type = lib.types.path;
                description = "sops-encrypted ssh_config fragment (binary format)";
              };
            }
          );
          default = { };
          description = ''
            private ssh_config fragments; each is decrypted to
            /run/secrets/ssh-fragment-<name> and included by ~/.ssh/config
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        # /run/secrets.d/<gen> is 0751 root:keys; the owning user can traverse
        # it but not list it, so fragments are included by explicit path below
        sops.secrets = lib.mapAttrs' (
          name: frag:
          lib.nameValuePair "ssh-fragment-${name}" {
            inherit (frag) sopsFile;
            format = "binary";
            owner = user;
            mode = "0400";
          }
        ) cfg.fragments;
      };
    };

  home =
    {
      lib,
      config,
      osConfig,
      ...
    }:
    let
      cfg = osConfig.features.ssh-client;
    in
    {
      config = lib.mkIf cfg.enable {
        programs.ssh = {
          enable = true;
          # opt out of home-manager's legacy defaults; everything lives in settings."*"
          enableDefaultConfig = false;

          # rendered first, so Tag directives in fragments are visible to the
          # Match tagged blocks below; a missing fragment is a debug1 line only
          includes = map (name: "/run/secrets/ssh-fragment-${name}") (lib.attrNames cfg.fragments);

          # a host carries exactly one Tag, so each block is a connection profile
          settings = {
            "Match tagged iap" = {
              IdentitiesOnly = true;
              IdentityFile = [ "~/.ssh/google_compute_engine" ];
              # vms get recreated; keep churned keys out of the main known_hosts
              StrictHostKeyChecking = "no";
              UserKnownHostsFile = "~/.ssh/known_hosts.gcp";
            };

            # initrd unlock, reached with `ssh -P luks <host>`; -P replaces the
            # fragment's Tag so this block stands alone. the initrd has no
            # tailscale, so the name resolves via the lan resolver as given
            "Match tagged luks" = {
              User = "root";
              RequestTTY = "yes";
              # initrd sshd has its own host keys on :22
              UserKnownHostsFile = "~/.ssh/known_hosts.initrd";
            };

            "Match tagged ts" = {
              HostName = "%h.magic.headscale";
              User = config.home.username;
            };

            "*" = {
              ForwardAgent = false;
              # gpg-agent stores keys received over ssh-add permanently
              AddKeysToAgent = "no";
              ServerAliveInterval = 60;
              ServerAliveCountMax = 3;
              ControlMaster = "auto";
              ControlPath = "~/.ssh/cm-%C";
              ControlPersist = "10m";
              HashKnownHosts = true;
              StrictHostKeyChecking = "accept-new";
              ConnectTimeout = 10;
              # ghostty's terminfo isn't on remotes; fall back to a universally-known value
              SetEnv.TERM = "xterm-256color";
              # no UserKnownHostsFile here: overriding it disables UpdateHostKeys
            };
          };
        };
      };
    };
}

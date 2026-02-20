# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}:

let
  packages = inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system};
in

{
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.self.nixosModules.yubikey
    inputs.self.nixosModules.sway
  ];

  yubikey.enable = true;

  stylix = {
    enable = true;
    polarity = "dark";
    image = "${inputs.assets}/wallpaper.png";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
  };

  virtualisation.docker = {
    enable = true;
    logDriver = "json-file";
  };

  # WARN:(matej) probably want to drop this in the future
  # i added this to get ruff working when installed via pip
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = options.programs.nix-ld.libraries.default;

  services.blueman.enable = true;
  security.polkit.enable = true;
  security.pki.certificateFiles = [ packages.ca-matheo-si ];

  services.gnome.gnome-keyring.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # Set your time zone.
  time.timeZone = "Europe/Ljubljana";
  environment.variables.TZ = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  #console = {
  #  font = "Lat2-Terminus16";
  #  keyMap = "us";
  #  #useXkbConfig = true;
  #};

  users.defaultUserShell = pkgs.zsh;
  users.users.matej = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/matej";
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQGLdINKzs+sEy62Pefng0bcedgU396+OryFgeH99/c janezicmatej"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDk00+Km03epQXQs+xEwwH3zcurACzkEH+kDOPBw6RQe openpgp:0xB095D449"
    ];
  };

  services.teamviewer.enable = true;
  users.groups.matej = {
    gid = 1000;
    members = [ "matej" ];
  };

  home-manager.backupFileExtension = "backup";
  home-manager.users.matej = {
    home.stateVersion = "24.11";
    home.packages = [ ];
  };

  programs.zsh = {
    enable = true;
  };
  environment.etc."zshenv".text = ''
    export ZDOTDIR=$HOME/.config/zsh
  '';

  # Wayland, X, etc. support for session vars
  # systemd.user.sessionVariables = config.home-manager.users.matej.home.sessionVariables; };

  # enable Sway window manager
  sway = {
    enable = true;
    cmdFlags = [ "--unsupported-gpu" ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
        user = "greeter";
      };
    };
  };
  # users.users.greeter = {
  #   isSystemUser = true;
  #   description = "greetd user";
  #   group = "nogroup";
  #   home = "/var/lib/greetd";
  # };

  programs.thunderbird.enable = true;
  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  services.playerctld.enable = true;

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
    maple-mono.NF
  ];

  programs.gnupg.agent = {
    enable = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  hardware.keyboard.zsa.enable = true;
  hardware.ledger.enable = true;

  environment.systemPackages = with pkgs; [
    # discord
    vesktop
    rocketchat-desktop
    telegram-desktop
    slack
    #
    ghostty
    mdbook
    pass
    google-chrome
    # nodejs
    pavucontrol
    protonmail-bridge
    python3
    zathura
    smartmontools
    marksman
    mdformat
    jellyfin-media-player
    cider-2
    libnotify # need this for runelite
    bolt-launcher
    ledger-live-desktop
  ];

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    # alsa.enable = true;
    # alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  services.dbus.enable = true;

  xdg = {
    portal = {
      xdgOpenUsePortal = true;
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
    };
    mime.defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = null;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

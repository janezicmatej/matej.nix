{ inputs, ... }:

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  packages = inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system};
in

{
  home.stateVersion = "24.11";

  # TODO:(janezicmatej) do i need this here?
  services.dunst.enable = true;

  home.packages = [
    pkgs.bibata-cursors
    pkgs.pinentry-curses

    pkgs.starship

    pkgs.claude-code

    # git and co
    pkgs.git
    packages.git-linearize
    packages.ggman

    # cli utils
    packages.ahab
    pkgs.fzf
    pkgs.htop
    pkgs.jc
    pkgs.jq
    pkgs.openssl
    pkgs.pv
    pkgs.python3
    pkgs.ripgrep
    pkgs.fd
    pkgs.tmux
    pkgs.osc
    pkgs.just

    # compilers, toolchains, ...
    pkgs.go
    # pkgs.gcc
    # pkgs.clang

    # need for gcp stuff
    pkgs.google-cloud-sdk
    pkgs.google-cloud-sql-proxy
  ];

  home.file.".assets".source = inputs.assets;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  stylix.targets.neovim.enable = false;
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;

    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

    extraPackages = with pkgs; [
      # runtime deps
      gcc
      luajit
      nodejs_22 # copilot

      # treesitter
      tree-sitter

      # lua_fzf
      fd
      ripgrep
      bat
      gnumake
      delta

      # language server
      pyright
      typescript-language-server
      lua-language-server
      gopls
      nil
      nixd

      # formatters
      nixpkgs-fmt
      stylua
    ];

    extraWrapperArgs = [
      "--suffix"
      "LD_LIBRARY_PATH"
      ":"
      "${lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}"
    ];
  };
}

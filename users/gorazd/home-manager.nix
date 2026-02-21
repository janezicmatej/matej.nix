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

  home.packages = [
    pkgs.git
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;

    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

    extraPackages = with pkgs; [
      # runtime deps
      fzf
      ripgrep
      gnumake
      gcc
      luajit

      lua-language-server
      nil
      nixd

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

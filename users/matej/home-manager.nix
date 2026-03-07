{
  pkgs,
  inputs,
  osConfig,
  ...
}:

{
  home.stateVersion = "24.11";

  # always-on
  shell.enable = true;
  dev.enable = true;
  neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  claude = {
    enable = true;
    package = inputs.claude-code-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  # desktop-conditional
  desktop.enable = osConfig.desktop.enable;
}

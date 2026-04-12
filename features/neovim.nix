{
  nixos =
    { lib, ... }:
    {
      options.features.neovim = {
        enable = lib.mkEnableOption "neovim";

        dotfiles = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
        };
      };
    };

  home =
    {
      config,
      options,
      lib,
      pkgs,
      inputs,
      osConfig,
      ...
    }:
    let
      cfg = osConfig.features.neovim;
    in
    {
      config = lib.mkIf cfg.enable (lib.mkMerge [
        (lib.optionalAttrs (options ? stylix) {
          # disable stylix neovim target when stylix is present
          stylix.targets.neovim.enable = false;
        })
        {
          xdg.configFile."nvim" = lib.mkIf (cfg.dotfiles != null) {
            source = cfg.dotfiles;
          };

          programs.neovim = {
            enable = true;
            vimAlias = true;
            defaultEditor = true;
            package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

            extraPackages = with pkgs; [
              gcc
              luajit
              nodejs_22
              tree-sitter
              gnumake
              osc

              fd
              ripgrep
              bat
              delta

              pyright
              typescript-language-server
              lua-language-server
              gopls
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
      ]);
    };
}

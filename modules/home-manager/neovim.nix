{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    neovim = {
      enable = lib.mkEnableOption "neovim nightly with lsp support";
      package = lib.mkPackageOption pkgs "neovim" { };
      dotfiles = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "path to neovim config directory";
      };
    };
  };

  config = lib.mkIf config.neovim.enable (
    lib.mkMerge [
      (lib.mkIf (config.neovim.dotfiles != null) {
        xdg.configFile."nvim".source = config.neovim.dotfiles;
      })
      {
        programs.neovim = {
          enable = true;
          vimAlias = true;
          defaultEditor = true;
          inherit (config.neovim) package;

          extraPackages = with pkgs; [
            # runtime deps
            gcc
            luajit
            nodejs_22
            tree-sitter
            gnumake
            osc

            # search and diff
            fd
            ripgrep
            bat
            delta

            # language servers
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
    ]
  );
}

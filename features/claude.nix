{
  nixos =
    { lib, ... }:
    {
      options.features.claude.enable = lib.mkEnableOption "claude";
    };

  home =
    { pkgs, lib, osConfig, ... }:
    let
      cfg = osConfig.features.claude;
    in
    {
      config = lib.mkIf cfg.enable {
        home.packages = [
          pkgs.claude-code
          pkgs.mcp-nixos
        ];
      };
    };
}

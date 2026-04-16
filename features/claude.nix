{
  nixos =
    { lib, ... }:
    {
      options.features.claude.enable = lib.mkEnableOption "claude";
    };

  home =
    {
      pkgs,
      lib,
      inputs,
      osConfig,
      ...
    }:
    let
      cfg = osConfig.features.claude;
      packages = inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      config = lib.mkIf cfg.enable {
        home.packages = [
          packages.claude-code
          pkgs.mcp-nixos
        ];
      };
    };
}

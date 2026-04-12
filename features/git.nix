{
  nixos =
    { lib, ... }:
    {
      options.features.git.enable = lib.mkEnableOption "git";
    };

  home =
    { pkgs, lib, inputs, osConfig, ... }:
    let
      cfg = osConfig.features.git;
      packages = inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      config = lib.mkIf cfg.enable {
        home.packages = [
          pkgs.git
          packages.git-linearize
          packages.ggman
        ];
      };
    };
}

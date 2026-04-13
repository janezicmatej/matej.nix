{
  nixos =
    { lib, ... }:
    {
      options.features.dev.enable = lib.mkEnableOption "development tools";
    };

  home =
    { pkgs, lib, inputs, osConfig, ... }:
    let
      cfg = osConfig.features.dev;
      packages = inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      config = lib.mkIf cfg.enable {
        home.packages = [
          pkgs.python3
          pkgs.osc

          pkgs.google-cloud-sdk
          pkgs.google-cloud-sql-proxy

          packages.ahab
          pkgs.just
          pkgs.presenterm
          pkgs.qemu
        ];
      };
    };
}

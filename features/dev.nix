{
  home =
    { pkgs, inputs, ... }:
    let
      packages = inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.packages = [
        pkgs.git
        packages.git-linearize
        packages.ggman

        pkgs.python3
        pkgs.osc

        pkgs.google-cloud-sdk
        pkgs.google-cloud-sql-proxy

        packages.ahab
        pkgs.just
        pkgs.presenterm
      ];

    };
}

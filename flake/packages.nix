{ inputs, ... }:

let
  my-lib = import ../lib { inherit (inputs.nixpkgs) lib; };
in
{
  perSystem =
    { pkgs, system, ... }:
    {
      packages =
        import ../packages
          {
            inherit my-lib;
            inherit (inputs.nixpkgs) lib;
          }
          {
            inherit pkgs;
            pkgs-master = inputs.nixpkgs-master.legacyPackages.${system};
          };
    };
}

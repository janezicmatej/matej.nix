_: {
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;

      devShells = {
        default = pkgs.mkShell {
          packages = [
            pkgs.pre-commit
            pkgs.statix
            pkgs.shellcheck
            pkgs.shfmt
            pkgs.qemu
            pkgs.sops
            pkgs.ssh-to-age
          ];
        };
      };
    };
}

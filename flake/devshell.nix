_: {
  perSystem =
    { pkgs, lib, ... }:
    let
      # libraries needed by python native extensions
      pythonLibraries = [
        pkgs.stdenv.cc.cc.lib
        pkgs.zlib
        pkgs.openssl
        pkgs.curl
      ];

      mkUv = python: {
        packages = [
          python
          pkgs.uv
        ];
        libraries = pythonLibraries;
        env = {
          UV_PYTHON_DOWNLOADS = "never";
          UV_PYTHON_PREFERENCE = "only-system";
          UV_PYTHON = "${python}/bin/python";
        };
        shellHook = ''
          unset PYTHONPATH
          export UV_PROJECT_ENVIRONMENT="$HOME/.venvs/$(basename "$PWD")-$(echo "$PWD" | md5sum | cut -c1-8)"
        '';
      };

      # composable dev environment components
      # each is exposed as its own devShell, layered via `use dev` in .envrc
      components = {
        uv_10 = mkUv pkgs.python310;
        uv_11 = mkUv pkgs.python311;
        uv_12 = mkUv pkgs.python312;
        uv_13 = mkUv pkgs.python313;
        uv_14 = mkUv pkgs.python314;

        pg_15 = {
          packages = [ pkgs.postgresql_15 ];
        };
        pg_16 = {
          packages = [ pkgs.postgresql_16 ];
        };
        pg_17 = {
          packages = [ pkgs.postgresql_17 ];
        };
        pg_18 = {
          packages = [ pkgs.postgresql_18 ];
        };

        rust = {
          packages = [
            pkgs.rustc
            pkgs.cargo
            pkgs.rust-analyzer
            pkgs.openssl
            pkgs.pkg-config
          ];
        };

        cmake = {
          packages = [
            pkgs.cmake
            pkgs.ninja
          ];
        };
      };

      mkComponentShell =
        component:
        let
          c = components.${component};
          libraries = c.libraries or [ ];
          libPath = lib.makeLibraryPath libraries;
        in
        pkgs.mkShell (
          {
            packages = c.packages or [ ];
            shellHook =
              (lib.optionalString (libraries != [ ]) ''
                export LD_LIBRARY_PATH="${libPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
              '')
              + (c.shellHook or "");
          }
          // lib.optionalAttrs (c ? env) { inherit (c) env; }
        );

      componentShells = lib.mapAttrs (name: _: mkComponentShell name) components;
    in
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
      }
      // componentShells;
    };
}

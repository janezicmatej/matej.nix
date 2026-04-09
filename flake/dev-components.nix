# composable dev environment components
# imported by generated per-project flakes via use_dev
{ pkgs, lib }:
let
  # libraries needed by python native extensions
  pythonLibraries = [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.openssl
    pkgs.curl
    pkgs.libffi
  ];

  mkNode = nodejs: {
    packages = [
      nodejs
      pkgs.corepack
    ];
    env = {
      COREPACK_ENABLE_STRICT = "0";
    };
  };

  mkUv = python: {
    packages = [
      python
      pkgs.uv
      pkgs.pkg-config
    ];
    libraries = pythonLibraries;
    env = {
      UV_PYTHON_DOWNLOADS = "never";
      UV_PYTHON_PREFERENCE = "only-system";
    };
    shellHook = ''
      unset PYTHONPATH
      export UV_PROJECT_ENVIRONMENT="''${XDG_DATA_HOME:-$HOME/.local/share}/dev-venvs/$(basename "$PWD")-$(echo "$PWD" | sha256sum | cut -c1-8)"
    '';
  };

  components = {
    uv_10 = mkUv pkgs.python310;
    uv_11 = mkUv pkgs.python311;
    uv_12 = mkUv pkgs.python312;
    uv_13 = mkUv pkgs.python313;
    uv_14 = mkUv pkgs.python314;

    node_20 = mkNode pkgs.nodejs_20;
    node_22 = mkNode pkgs.nodejs_22;
    node_24 = mkNode pkgs.nodejs_24;

    rust = {
      packages = [
        pkgs.rustc
        pkgs.cargo
        pkgs.rust-analyzer
        pkgs.openssl
        pkgs.pkg-config
      ];
    };

  };

  # build a single mkShell from one or more component names
  mkComponentShell =
    names: extraPackages:
    let
      selected = map (n: components.${n}) names;
      allPackages = lib.concatMap (c: c.packages or [ ]) selected ++ extraPackages;
      allLibraries = lib.concatMap (c: c.libraries or [ ]) selected;
      allHooks = lib.concatMapStrings (c: c.shellHook or "") selected;
      allEnvs = lib.foldl' (acc: c: acc // (c.env or { })) { } selected;
      libPath = lib.makeLibraryPath allLibraries;
    in
    pkgs.mkShell (
      {
        packages = allPackages;
        shellHook =
          (lib.optionalString (allLibraries != [ ]) ''
            export LD_LIBRARY_PATH="${libPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          '')
          + allHooks;
      }
      // lib.optionalAttrs (allEnvs != { }) { env = allEnvs; }
    );
in
{
  inherit components mkComponentShell;
}

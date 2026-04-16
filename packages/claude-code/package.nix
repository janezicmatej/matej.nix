{ pkgs, ... }:

pkgs.buildNpmPackage (finalAttrs: {
  pname = "claude-code";
  version = "2.1.111";

  src = pkgs.fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${finalAttrs.version}.tgz";
    hash = "sha256-K3qhZXVJ2DIKv7YL9f/CHkuUYnK0lkIR1wjEa+xeSCk=";
  };

  npmDepsHash = "sha256-6f68qUMnDk6tn+qypVi8bPtNrxbtcf15tHrgtlhEaK4=";

  strictDeps = true;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json

    substituteInPlace cli.js \
          --replace-fail '#!/bin/sh' '#!/usr/bin/env sh'
  '';

  dontNpmBuild = true;

  env.AUTHORIZED = "1";

  postInstall = ''
    wrapProgram $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1 \
      --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
      --set DISABLE_INSTALLATION_CHECKS 1 \
      --unset DEV \
      --prefix PATH : ${
        pkgs.lib.makeBinPath (
          [
            pkgs.procps
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.bubblewrap
            pkgs.socat
          ]
        )
      }
  '';

  meta = {
    description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
    homepage = "https://github.com/anthropics/claude-code";
    downloadPage = "https://www.npmjs.com/package/@anthropic-ai/claude-code";
    license = pkgs.lib.licenses.unfree;
    mainProgram = "claude";
  };
})

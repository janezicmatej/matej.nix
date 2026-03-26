{
  home =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.claude-code
        pkgs.mcp-nixos
      ];
    };
}

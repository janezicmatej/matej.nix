{
  nixos =
    { inputs, ... }:
    {
      nix.registry.dev = {
        from = {
          type = "indirect";
          id = "dev";
        };
        to = {
          type = "path";
          path = inputs.self.outPath;
        };
      };
    };
}

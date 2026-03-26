{
  nixos = _: {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
  };
}

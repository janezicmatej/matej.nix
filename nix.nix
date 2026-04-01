{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      download-buffer-size = 2 * 1024 * 1024 * 1024;
      warn-dirty = false;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org?priority=45"
        "http://tower:5000?priority=50"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "matej.nix-1:TdbemLVYblvAxqJcwb3mVKmmr3cfzXbMcZHE5ILnZDE="
      ];
    };

    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };

    optimise = {
      automatic = true;
      dates = [ "monthly" ];
    };
  };
}

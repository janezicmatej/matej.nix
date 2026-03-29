{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      download-buffer-size = 2 * 1024 * 1024 * 1024;
      warn-dirty = false;
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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

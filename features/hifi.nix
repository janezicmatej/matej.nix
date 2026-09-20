{
  nixos =
    { config, lib, ... }:
    let
      cfg = config.features.hifi;
    in
    {
      options.features.hifi = {
        enable = lib.mkEnableOption "bit-perfect pipewire output for an external dac";

        # graph rate while idle; spotify lossless is 44.1k so a 44.1k-only
        # session never resamples
        defaultRate = lib.mkOption {
          type = lib.types.int;
          default = 44100;
        };

        # rates the graph may switch to when the sink is idle; must be a subset
        # of what the dac accepts
        allowedRates = lib.mkOption {
          type = lib.types.listOf lib.types.int;
          default = [
            44100
            48000
            88200
            96000
            176400
            192000
          ];
        };

        # resampler quality for streams that still get resampled (48k browser
        # audio while the graph sits at 44.1k); pipewire default is 4, max 14
        resampleQuality = lib.mkOption {
          type = lib.types.ints.between 0 14;
          default = 10;
        };
      };

      config = lib.mkIf cfg.enable {
        services.pipewire.extraConfig = {
          pipewire."10-hifi-clock" = {
            "context.properties" = {
              "default.clock.rate" = cfg.defaultRate;
              "default.clock.allowed-rates" = cfg.allowedRates;
            };
          };

          pipewire-pulse."10-hifi-resample" = {
            "stream.properties"."resample.quality" = cfg.resampleQuality;
          };

          client."10-hifi-resample" = {
            "stream.properties"."resample.quality" = cfg.resampleQuality;
          };
        };
      };
    };
}

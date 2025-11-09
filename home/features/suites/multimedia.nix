{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.suites.multimedia;
in {
  options.features.suites.multimedia.enable = mkEnableOption "multimedia suite";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Media
      vlc
      cava
      cmatrix
      yt-dlp
      qpwgraph
      #amberol
      #jellyfin-media-player
    ];
  };
}

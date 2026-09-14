{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.lampa;
in
{
  options.features.desktop.lampa.enable = mkEnableOption "LAMPA desktop media center client";

  # LAMPA doesn't download torrents itself -- point it at a local TorrServer
  # (common.services.torrserver on the NixOS side) from inside the app:
  # Settings -> Torrent client -> external TorrServer -> http://127.0.0.1:8090
  config = mkIf cfg.enable {
    home.packages = [ pkgs.lampa-desktop ];

    xdg.desktopEntries.lampa = {
      name = "Lampa";
      exec = "lampa-desktop";
      icon = "lampa-desktop";
      type = "Application";
      categories = [
        "AudioVideo"
        "Player"
      ];
    };
  };
}

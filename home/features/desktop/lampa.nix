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

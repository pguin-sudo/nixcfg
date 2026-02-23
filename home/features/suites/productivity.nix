{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.suites.productivity;
in
{
  options.features.suites.productivity.enable = mkEnableOption "productivity suite";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Productivity
      telegram-desktop
      obsidian
      qbittorrent
      #webcord
      #bottles
      #tailscale

      onlyoffice-desktopeditors
      obs-studio
    ];
  };
}

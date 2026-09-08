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
      iloader # sideload .ipa files onto iPhone
      #webcord
      #tailscale

      bottles
      wineWowPackages.stable # 32/64-bit wine
      winetricks

      onlyoffice-desktopeditors
      obs-studio
    ];
  };
}

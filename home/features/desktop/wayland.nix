{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.wayland;
in {
  options.features.desktop.wayland.enable = mkEnableOption "wayland extra tools and config";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      grim
      hyprcursor
      hyprlock
      hyprpaper
      qt6.qtwayland
      slurp
      waypipe
      wl-clipboard
      wf-recorder
      wl-mirror
      wlogout
      wtype
      ydotool
    ];
  };
}


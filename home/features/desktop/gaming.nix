{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.gaming;
in {
  options.features.desktop.gaming.enable =
    mkEnableOption "install gaming related stuff";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gamescope
      goverlay
      mangohud
    ];
  };
}


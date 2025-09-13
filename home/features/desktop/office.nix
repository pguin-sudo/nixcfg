{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.office;
in {
  options.features.desktop.office.enable =
    mkEnableOption "install office and paperwork stuff";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-fresh
    ];
  };
}


{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.reticulum;
in {
  options.features.cli.reticulum.enable = mkEnableOption "enable reticulum";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      python313Packages.nomadnet
      python313Packages.lxmf
      rns

      i2pd
    ];
  };
}

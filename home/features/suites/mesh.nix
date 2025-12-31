{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.suites.mesh;
in {
  options.features.suites.mesh.enable = mkEnableOption "enable software for mesh networks";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      python313Packages.nomadnet
      python313Packages.lxmf
      rns

      # Custom
      chromium
      meshchat
      #meshradar
    ];
  };
}

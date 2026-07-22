{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.suites.mesh;
in
{
  options.features.suites.mesh.enable = mkEnableOption "enable software for mesh networks";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      python313Packages.nomadnet
      python313Packages.lxmf
      python313Packages.bleak
      rns
      # Custom
      chromium
      meshchatx
    ];

    systemd.user.services.rnsd = {
      Unit = {
        Description = "Reticulum Network Stack daemon";
        After = [
          "network.target"
          "bluetooth.target"
        ];
        Wants = [ "network.target" ];
      };
      Service = {
        ExecStart = "${pkgs.rns}/bin/rnsd --service";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}

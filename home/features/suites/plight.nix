{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.themes.plight;
in {
  options.features.themes.plight.enable = mkEnableOption "plight service";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      plight
    ];

    systemd.user.services.plight = {
      Unit = {
        Description = "PLight - dynamic backlighting";
        After = ["graphical-session.target" "pipewire.service"];
        Requires = ["pipewire.service"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.plight}/bin/plight";
        Restart = "always";
        RestartSec = 3;

        Environment = [
          "RUST_LOG=info"
        ];

        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        PrivateTmp = true;
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}

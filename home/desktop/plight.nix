{ pkgs, ... }:
{
  home.packages = [ pkgs.plight ];

  systemd.user.services.plight = {
    Unit = {
      Description = "PLight - dynamic backlighting";
      After = [
        "graphical-session.target"
        "pipewire.service"
      ];
      Requires = [ "pipewire.service" ];
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
      ReadWritePaths = [ "%h/.config/plight" ];
      PrivateTmp = true;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}

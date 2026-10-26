{ pkgs, ... }:
{
  home.packages = [ pkgs.torrserver ];

  # LAMPA (home/desktop/lampa.nix) streams torrents through TorrServer rather
  # than natively -- add it as a server in LAMPA's own settings (Настройки ->
  # Торрент-клиент -> Свой сервер) pointing at http://127.0.0.1:8090 once this
  # service is up.
  systemd.user.services.torrserver = {
    Unit = {
      Description = "TorrServer - torrent streaming server (LAMPA backend)";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      # %S expands to the StateDirectory below; kept out of $HOME proper so
      # ProtectHome=read-only can stay on.
      ExecStart = "${pkgs.torrserver}/bin/torrserver --port 8090 --path %S/torrserver";
      Restart = "always";
      RestartSec = 3;

      StateDirectory = "torrserver";

      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      PrivateTmp = true;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}

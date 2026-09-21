{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.common.services.hotspot;
in
{
  options.common.services.hotspot = {
    enable = mkEnableOption "sharing internet over a wifi hotspot via NetworkManager";

    interface = mkOption {
      type = types.str;
      example = "wlan0";
      description = "Name of the wlan interface used to broadcast the hotspot.";
    };

    environmentFile = mkOption {
      type = types.path;
      default = "/etc/hotspot-secrets.env";
      example = "/run/secrets/hotspot.env";
      description = ''
        Path to a plain file (systemd EnvironmentFile format, e.g. `HOTSPOT_SSID=...`)
        that defines `HOTSPOT_SSID` and `HOTSPOT_PSK`. This file lives outside the Nix
        store and outside the git repo, so the hotspot credentials never end up in
        either. Create it manually on the host, e.g.:
          printf 'HOTSPOT_SSID=MyNetwork\nHOTSPOT_PSK=supersecret\n' > /etc/hotspot-secrets.env
          chmod 600 /etc/hotspot-secrets.env
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.networkmanager.ensureProfiles = {
      environmentFiles = [ cfg.environmentFile ];
      profiles.hotspot = {
        connection = {
          id = "hotspot";
          type = "wifi";
          interface-name = cfg.interface;
          autoconnect = true;
        };
        wifi = {
          mode = "ap";
          ssid = "$HOTSPOT_SSID";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$HOTSPOT_PSK";
        };
        ipv4.method = "shared";
        ipv6.method = "ignore";
      };
    };

    # Клиенты за хотспотом объявляют MSS по своему локальному MTU 1500, но весь
    # исходящий трафик delta уходит в AmneziaWG-туннель с MTU 1280. Сегменты по
    # 1460 байт в него не влезают, ICMP "fragmentation needed" до клиента не
    # доезжает, PMTUD проваливается -- и TLS-хендшейк с большим Client Hello
    # (например duckduckgo.com) виснет. Своему трафику delta ядро подставляет MSS
    # по MTU маршрута само, форвардимому -- нет, отсюда это правило.
    #
    # Матчим по входу с хотспота, а не по выходу в туннель: имя VPN-интерфейса --
    # это slug хоста из vpn://-ссылки, который vpnctl генерирует в рантайме
    # (pkgs/vpnctl/src/vpnctl/sources.py), в nix его нет и он меняется при смене
    # сервера. `rt mtu` берёт MTU фактического маршрута, поэтому в туннель уйдёт
    # MSS 1240, а в LAN через eno1 -- 1460, то есть без изменений.
    networking.nftables.tables.mss-clamp = {
      family = "inet";
      content = ''
        chain forward {
          type filter hook forward priority mangle; policy accept;
          iifname "${cfg.interface}" tcp flags syn tcp option maxseg size set rt mtu
        }
      '';
    };
  };
}

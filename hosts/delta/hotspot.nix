{ ... }:
{
  # Wifi hotspot: share internet through the wlan adapter while delta is on.
  # SSID/password are NOT here -- create /etc/hotspot-secrets.env with
  #   HOTSPOT_SSID=... and HOTSPOT_PSK=... (chmod 600, out of the Nix store).
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ "/etc/hotspot-secrets.env" ];
    profiles.hotspot = {
      connection = {
        id = "hotspot";
        type = "wifi";
        interface-name = "wlp2s0f0u5";
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
  # виснет. Своему трафику delta ядро подставляет MSS по MTU маршрута само,
  # форвардимому -- нет, отсюда это правило.
  #
  # Матчим по входу с хотспота, а не по выходу в туннель: имя VPN-интерфейса
  # меняется при смене сервера (vpnctl генерирует его в рантайме). `rt mtu`
  # берёт MTU фактического маршрута, поэтому в туннель уйдёт MSS 1240, а в
  # LAN через eno1 -- 1460, то есть без изменений.
  networking.nftables.tables.mss-clamp = {
    family = "inet";
    content = ''
      chain forward {
        type filter hook forward priority mangle; policy accept;
        iifname "wlp2s0f0u5" tcp flags syn tcp option maxseg size set rt mtu
      }
    '';
  };
}

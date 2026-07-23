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
  };
}

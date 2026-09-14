{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.common.services.torrserver;
in
{
  options.common.services.torrserver = {
    enable = mkEnableOption "TorrServer torrent-streaming backend (used by LAMPA as an external torrent client)";

    enableGst = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Build/run TorrServer with GStreamer support (HLS streaming, transcoding
        of DTS/AC3/HDR->SDR). Leave off for Direct Play only.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8090;
      description = "HTTP port TorrServer listens on.";
    };

    bindAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = ''
        Address TorrServer binds to. Defaults to localhost, for a LAMPA client
        running on this same machine. Set to "" (all interfaces) together with
        `openFirewall` to let LAMPA on other devices on the LAN reach it.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open `port` in the firewall. Only useful once bindAddress is not 127.0.0.1.";
    };
  };

  # Upstream module (torrserver.nixosModules.default): dataDir/readOnlyDb/
  # httpAuth/extraFlags are also available directly under services.torrserver
  # if ever needed -- not wrapped here since the defaults cover the LAMPA use
  # case. Note dataDir is currently a no-op upstream: ExecStart hardcodes
  # --path /var/lib/torrserver regardless of that option (confirmed by reading
  # module.nix 2026-09-13).
  config = mkIf cfg.enable {
    services.torrserver = {
      enable = true;
      inherit (cfg) enableGst port bindAddress openFirewall;
    };
  };
}

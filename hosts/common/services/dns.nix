{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.common.services.dns;
in
{
  options.common.services.dns.enable = mkEnableOption "enable dns";
  config = mkIf cfg.enable {
    services.resolved.enable = mkForce false;

    networking.resolvconf.useLocalResolver = true;

    services.dnscrypt-proxy = {
      enable = true;
      settings = {
        listen_addresses = [ "127.0.0.1:53" ];
        ipv6_servers = false;
        require_dnssec = true;

        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };

        # No server_names restriction: let dnscrypt-proxy auto-pick the
        # fastest server among all that satisfy require_dnssec/require_nolog/
        # require_nofilter, and fail over automatically if one goes down.
        # Pinning to a single resolver (previously just "cloudflare") means
        # total DNS outage if that one resolver is unreachable or blocked.
      };
    };

    # Wants= alone doesn't order startup against the network coming up --
    # without an explicit After=, dnscrypt-proxy can start probing upstream
    # servers before the interface is actually routable, which stalls all
    # system DNS for as long as that probing takes (observed: ~2.5min).
    systemd.services.dnscrypt-proxy.after = [ "network-online.target" ];
  };
}

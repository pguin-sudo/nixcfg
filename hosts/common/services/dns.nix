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
    #services.resolved.enable = mkForce false;
    #networking.useDHCP = mkForce false;
    #networking.networkmanager.dns = "none";

    networking.nameservers = [
      "127.0.2.1:53"
    ];

    services.dnscrypt-proxy = {
      enable = true;
      settings = {
        listen_addresses = [ "127.0.2.1" ];
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

        server_names = [ "cloudflare" ];
      };
    };
  };
}

{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.common.services.steam;
in
{
  options.common.services.steam.enable = mkEnableOption "enable steam";

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    networking.firewall = {
      enable = false;

      allowedUDPPorts = [
        24642
        27036
        5900
      ];
      allowedTCPPorts = [ 24643 ];

      allowedUDPPortRanges = [
        {
          from = 27000;
          to = 27100;
        }
      ];
    };
  };
}

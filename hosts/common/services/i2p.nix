{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.common.services.i2p;
in
{
  options.common.services.i2p.enable = mkEnableOption "enable obs-studio";

  config = mkIf cfg.enable {
    services.i2pd = {
      enable = true;
      settings = {
        http.enabled = true;
        httpproxy.enabled = true;
        socksproxy.enabled = true;
        sam.enabled = true;
        i2cp = {
          enabled = true;
          address = "127.0.0.1";
          port = 7654;
        };
      };
    };
  };
}

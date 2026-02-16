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
      address = "127.0.0.1";
      proto = {
        http.enable = true;
        socksProxy.enable = true;
        httpProxy.enable = true;
        sam.enable = true;
        i2cp = {
          enable = true;
          address = "127.0.0.1";
          port = 7654;
        };
      };
    };
  };
}

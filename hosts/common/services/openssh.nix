{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.common.services.openssh;
in {
  options.common.services.openssh.enable = mkEnableOption "enable windows vm";

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [22];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = ["pguin"];
      };
    };
  };
}

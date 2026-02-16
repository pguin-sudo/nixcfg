{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.common.services.throne;
in
{
  options.common.services.throne.enable = mkEnableOption "enable throne";

  config = mkIf cfg.enable {
    programs.throne = {
      enable = true;
      tunMode.enable = true;
      tunMode.setuid = true;
    };
  };
}

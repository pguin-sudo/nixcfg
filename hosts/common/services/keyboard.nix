{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.common.services.keyboard;
in
{
  options.common.services.keyboard.enable = mkEnableOption "enable throne";
  config = mkIf cfg.enable {
    hardware.keyboard.qmk.enable = true;
    environment.systemPackages = with pkgs; [
      vial
      qmk
    ];
    services.udev.packages = with pkgs; [
      vial
    ];
  };
}

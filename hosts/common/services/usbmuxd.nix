{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.common.services.usbmuxd;
in {
  options.common.services.usbmuxd.enable = mkEnableOption "enable usbmuxd";

  config = mkIf cfg.enable {
    services.usbmuxd.enable = true;
  };
}

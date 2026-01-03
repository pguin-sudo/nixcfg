{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.common.services.dm;
in {
  options.common.services.dm.enable = mkEnableOption "enable dm";

  config = mkIf cfg.enable {
    services.displayManager = {
      enable = true;
      defaultSession = "hyprland";
      ly = {
        enable = true;
      };
    };

    programs.hyprland.enable = true;
  };
}

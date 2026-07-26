{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.common.services.obs-studio;
in {
  options.common.services.obs-studio.enable = mkEnableOption "enable kernel modules for obs-studio";

  config = mkIf cfg.enable {
    boot.extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    # Howdy is currently disabled repo-wide, so it no longer conflicts with autoloading here
    boot.kernelModules = ["v4l2loopback"];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1
    '';
    # So the module can be picked up without sudo/pkexec
    security.polkit.enable = true;
  };
}

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.dms;
in
{
  options.features.desktop.dms.enable = mkEnableOption "dms";
  imports = [ inputs.dms.homeModules.dank-material-shell ];

  # https://danklinux.com/docs/dankmaterialshell/nixos-flake
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      dgop
      #khal
      cava
      cliphist
      wl-clipboard
      dsearch
    ];

    programs.dank-material-shell = {
      enable = true;

      systemd = {
        enable = false;
        restartIfChanged = false;
      };

      enableSystemMonitoring = true;
      enableVPN = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
    };

    # settings.json managed as mutable file via mkOutOfStoreSymlink so DMS UI changes
    # write through the symlink into the nixcfg repo (same as GNU Stow approach on Arch)
    home.file.".config/DankMaterialShell/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nixcfg/home/resources/dms-settings.json";
  };
}

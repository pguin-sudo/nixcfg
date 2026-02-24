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
  scheme = config.lib.stylix.colors;
  hexToRgb =
    color:
    let
      r = builtins.substring 0 2 color;
      g = builtins.substring 2 2 color;
      b = builtins.substring 4 2 color;
    in
    {
      r = (builtins.fromTOML "v = 0x${r}").v;
      g = (builtins.fromTOML "v = 0x${g}").v;
      b = (builtins.fromTOML "v = 0x${b}").v;
    };
  rgba =
    color: alpha:
    let
      rgb = hexToRgb color;
    in
    "rgba(${toString rgb.r}, ${toString rgb.g}, ${toString rgb.b}, ${toString alpha})";
in
{
  options.features.desktop.dms.enable = mkEnableOption "dms";
  imports = [ inputs.dms.homeModules.dank-material-shell ];

  # https://danklinux.com/docs/dankmaterialshell/nixos-flake
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      dgop
      khal
      cava
      cliphist
      wl-clipboard
      dsearch
    ];

    programs.dank-material-shell = {
      enable = true;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      enableSystemMonitoring = true;
      enableVPN = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;

      settings = {
        theme = "dark";
        dynamicTheming = true;
        showFocusedWindow = false;
      };

      session = {
        isLightMode = false;
        wallpaperPath = "/home/pguin/Wallpapers/catppuccin/Flowers.jpg";
        perMonitorWallpaper = false;
        wallpaperTransition = "fade";
        nightModeEnabled = false;
        latitude = 0;
        longitude = 0;
        nightModeUseIPLocation = false;
        weatherLocation = "New York, NY";
        weatherCoordinates = "55.1540,61.4292";
      };

      clipboardSettings = {
        maxHistory = 25;
        maxEntrySize = 5242880;
        autoClearDays = 1;
        clearAtStartup = true;
        disabled = false;
        disableHistory = false;
        disablePersist = true;
      };

      # Only avaliable via hosts (not home manager)
      #greeter = {
      #  enable = true;
      #  compositor.name = "hyprland"; # Or "hyprland" or "sway"
      #};
    };
  };
}

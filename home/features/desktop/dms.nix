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
    "rgba(${toString rgb.r}, ${toString rgb.g}, ${toString rgb.b}, ${toString alpha}";
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
      enableDynamicTheming = false;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;

      settings = {
        theme = "dark";
        dynamicTheming = true;
        showFocusedWindow = false;
        currentThemeName = "custom";
        customThemeFile = "/home/pguin/.config/dms/stylix-theme.json";
      };

      session = {
        isLightMode = false;
        wallpaperPath = "/home/pguin/Wallpapers/catppuccin/Flowers.jpg";
        perMonitorWallpaper = false;
        wallpaperTransition = "fade";
        nightModeEnabled = false;
        latitude = 55.1540;
        longitude = 61.4292;
        nightModeUseIPLocation = false;
        #weatherLocation = "Chelyabinsk";
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
    };

    home.file.".config/dms/stylix-theme.json".text = ''
      {
        "dark": {
          "name": "Stylix Theme Dark",
          "primary": "#${scheme.base0D}",
          "primaryText": "#${scheme.base00}",
          "primaryContainer": "#${scheme.base0C}",
          "secondary": "#${scheme.base0E}",
          "surface": "#${scheme.base00}",
          "surfaceText": "#${scheme.base05}",
          "surfaceVariant": "#${scheme.base01}",
          "surfaceVariantText": "#${scheme.base04}",
          "surfaceTint": "#${scheme.base0C}",
          "background": "#${scheme.base00}",
          "backgroundText": "#${scheme.base07}",
          "outline": "#${scheme.base03}",
          "surfaceContainer": "#${scheme.base01}",
          "surfaceContainerHigh": "#${scheme.base02}",
          "surfaceContainerHighest": "#${scheme.base03}",
          "error": "#${scheme.base08}",
          "warning": "#${scheme.base09}",
          "info": "#${scheme.base0D}",
          "matugen_type": "scheme-expressive"
        },
        "light": {
          "name": "Stylix Theme Light",
          "primary": "#${scheme.base0D}",
          "primaryText": "#${scheme.base07}",
          "primaryContainer": "#${scheme.base0C}",
          "secondary": "#${scheme.base0E}",
          "surface": "#${scheme.base07}",
          "surfaceText": "#${scheme.base01}",
          "surfaceVariant": "#${scheme.base06}",
          "surfaceVariantText": "#${scheme.base02}",
          "surfaceTint": "#${scheme.base0C}",
          "background": "#${scheme.base07}",
          "backgroundText": "#${scheme.base00}",
          "outline": "#${scheme.base03}",
          "surfaceContainer": "#${scheme.base06}",
          "surfaceContainerHigh": "#${scheme.base05}",
          "surfaceContainerHighest": "#${scheme.base04}",
          "error": "#${scheme.base08}",
          "warning": "#${scheme.base09}",
          "info": "#${scheme.base0D}",
          "matugen_type": "scheme-expressive"
        }
      }
    '';

  };
}

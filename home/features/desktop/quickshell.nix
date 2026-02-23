{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.quickshell;
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
  options.features.desktop.quickshell.enable = mkEnableOption "quickshell";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      quickshell
      dgop
    ];

    home.file.".config/quickshell" = {
      source = ../../resources/Quickshell;
      recursive = true;
    };
  };
}

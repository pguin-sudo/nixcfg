{ pkgs, ... }:
{
  home.packages = with pkgs; [
    blender
    krita
    audacity
    inkscape
  ];
}

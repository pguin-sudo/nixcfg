{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./desktop/rgb.nix
    ./desktop/plight.nix
    ./packages/studio.nix
  ];

  home.packages = [ pkgs.nvtopPackages.nvidia ];
  home.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
}

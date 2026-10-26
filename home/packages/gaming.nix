{ pkgs, ... }:
{
  # Steam installed in host config

  home.packages = with pkgs; [
    vesktop
    gzdoom
    prismlauncher-cracked
    osu-lazer-bin
  ];
}

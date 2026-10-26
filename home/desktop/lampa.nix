{ pkgs, ... }:
{
  home.packages = [ pkgs.lampa-desktop ];

  xdg.desktopEntries.lampa = {
    name = "Lampa";
    exec = "lampa-desktop";
    icon = "lampa-desktop";
    type = "Application";
    categories = [
      "AudioVideo"
      "Player"
    ];
  };
}

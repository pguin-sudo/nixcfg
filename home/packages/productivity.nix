{ pkgs, ... }:
{
  home.packages = with pkgs; [
    telegram-desktop
    obsidian
    qbittorrent
    iloader
    kdePackages.filelight

    bottles
    wineWow64Packages.stable # 32/64-bit wine
    winetricks

    onlyoffice-desktopeditors
    obs-studio
  ];
}

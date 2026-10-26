{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vlc
    cava
    cmatrix
    yt-dlp
    qpwgraph
    easyeffects
  ];

  services.nextcloud-client.enable = true;
}

{
  config,
  pkgs,
  ...
}:
let
  browserDesktopFile = "${config.home.sessionVariables.BROWSER or "firefox"}.desktop";
in
{
  home.packages = with pkgs; [
    wl-clipboard
    wtype

    pamixer
    pavucontrol
    playerctl

    brightnessctl
    kdePackages.kdeconnect-kde

    libnotify

    # Mime & xdg
    xdg-utils
    shared-mime-info

    # Images
    swayimg

    # For checking keybinds
    wev

    # Hyprland
    wayvnc
  ];

  home.file."Wallpapers" = {
    source = ../resources/Wallpapers;
    recursive = true;
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-termfilechooser
      ];

      # Without this, the FileChooser interface has no backend matching
      # UseIn=Hyprland (xdg-desktop-portal-gtk only advertises UseIn=gnome),
      # which is why browsers/apps were falling back to launching a full
      # Dolphin window instead of a proper file picker.
      config = {
        common.default = [
          "hyprland"
          "gtk"
        ];
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };
      };
    };

    configFile."xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
      default_dir=$HOME
      env=TERMCMD=kitty
      open_mode=suggested
      save_mode=suggested
    '';

    desktopEntries.yazi = {
      name = "Yazi";
      genericName = "File Manager";
      comment = "Terminal file manager";
      exec = "kitty --title yazi -e yazi %U";
      terminal = false;
      icon = "yazi";
      categories = [
        "System"
        "FileManager"
      ];
      mimeType = [ "inode/directory" ];
    };

    mimeApps = {
      enable = true;

      defaultApplications = {
        "inode/directory" = [ "yazi.desktop" ];
        "x-scheme-handler/file" = [ "yazi.desktop" ];

        "x-scheme-handler/http" = [ browserDesktopFile ];
        "x-scheme-handler/https" = [ browserDesktopFile ];
        "x-scheme-handler/about" = [ browserDesktopFile ];
        "x-scheme-handler/unknown" = [ browserDesktopFile ];
        "application/pdf" = [ browserDesktopFile ];

        "image/jpeg" = [ "swayimg.desktop" ];
        "image/jpg" = [ "swayimg.desktop" ];
        "image/png" = [ "swayimg.desktop" ];
        "image/gif" = [ "swayimg.desktop" ];
        "image/webp" = [ "swayimg.desktop" ];
        "image/tiff" = [ "swayimg.desktop" ];
        "image/bmp" = [ "swayimg.desktop" ];
        "image/svg+xml" = [ "swayimg.desktop" ];
        "image/x-icon" = [ "swayimg.desktop" ];

        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
          "onlyoffice-desktopeditors.desktop"
        ]; # .docx
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
          "onlyoffice-desktopeditors.desktop"
        ]; # .xlsx
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
          "onlyoffice-desktopeditors.desktop"
        ]; # .pptx
        "application/msword" = [ "onlyoffice-desktopeditors.desktop" ];
        "application/vnd.ms-excel" = [ "onlyoffice-desktopeditors.desktop" ];
        "application/vnd.ms-powerpoint" = [ "onlyoffice-desktopeditors.desktop" ];
        "application/vnd.oasis.opendocument.text" = [ "onlyoffice-desktopeditors.desktop" ];
        "application/vnd.oasis.opendocument.spreadsheet" = [ "onlyoffice-desktopeditors.desktop" ];
        "application/vnd.oasis.opendocument.presentation" = [ "onlyoffice-desktopeditors.desktop" ];

        "text/plain" = [ "nvim.desktop" ];
        "text/x-c" = [ "nvim.desktop" ];
        "text/x-c++" = [ "nvim.desktop" ];
        "text/x-python" = [ "nvim.desktop" ];
        "text/x-shellscript" = [ "nvim.desktop" ];
        "text/markdown" = [ "nvim.desktop" ];
        "text/x-diff" = [ "nvim.desktop" ];
        "application/x-yaml" = [ "nvim.desktop" ];

        "video" = [ "vlc.desktop" ];

        "application/octet-stream" = [ "kitty.desktop" ];
        "application/x-executable" = [ "kitty.desktop" ];
        "application/x-shellscript" = [ "kitty.desktop" ];
      };
    };

  };

  # Small fix for home-manager
  dconf.enable = false;
}

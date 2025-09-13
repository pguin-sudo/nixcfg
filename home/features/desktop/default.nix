{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./fonts.nix
    ./gaming.nix
    ./hyprland.nix
    ./media.nix
    ./office.nix
    ./rofi.nix
    ./theme.nix
    ./wayland.nix
  ];

  xdg = {
    enable = true;
    configFile."mimeapps.list".force = true;
    mimeApps = {
      enable = true;
      associations.added = {
        "application/zip" = ["org.gnome.FileRoller.desktop"];
        "application/csv" = ["calc.desktop"];
        "application/pdf" = ["okularApplication_pdf.desktop"];
      };
      defaultApplications = {
        "application/zip" = ["org.gnome.FileRoller.desktop"];
        "application/csv" = ["calc.desktop"];
        "application/pdf" = ["okularApplication_pdf.desktop"];
        "application/md" = ["nvim.desktop"];
        "application/text" = ["nvim.desktop"];
        "x-scheme-handler/http" = ["io.github.zen_browser.zen"];
        "x-scheme-handler/https" = ["io.github.zen_browser.zen"];
      };
    };
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.sessionVariables = {
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";
    NIXOS_OZONE_WL = "1";
    TERMINAL = "kitty";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };
  home.sessionPath = ["\${XDG_BIN_HOME}" "\${HOME}/.cargo/bin" "$HOME/.npm-global/bin"];

  fonts.fontconfig.enable = true;

  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableFishIntegration = true;
      enableBashIntegration = true;
    };
    font = {name = "Fira Code";};

    settings = {
      copy_on_select = "yes";

      # Base colors
      foreground = "#${config.colorScheme.palette.base05}";
      background = "#${config.colorScheme.palette.base00}";
      selection_foreground = "#${config.colorScheme.palette.base07}";
      selection_background = "#${config.colorScheme.palette.base02}";

      # URL color
      url_color = "#${config.colorScheme.palette.base08}";

      # Cursor
      cursor = "#${config.colorScheme.palette.base05}";
      cursor_text_color = "#${config.colorScheme.palette.base00}";

      # Colors 0-15
      color0 = "#${config.colorScheme.palette.base01}";
      color8 = "#${config.colorScheme.palette.base03}";

      color1 = "#${config.colorScheme.palette.base08}";
      color9 = "#${config.colorScheme.palette.base08}";

      color2 = "#${config.colorScheme.palette.base0B}";
      color10 = "#${config.colorScheme.palette.base0B}";

      color3 = "#${config.colorScheme.palette.base0A}";
      color11 = "#${config.colorScheme.palette.base0A}";

      color4 = "#${config.colorScheme.palette.base0D}";
      color12 = "#${config.colorScheme.palette.base0D}";

      color5 = "#${config.colorScheme.palette.base0E}";
      color13 = "#${config.colorScheme.palette.base0E}";

      color6 = "#${config.colorScheme.palette.base0C}";
      color14 = "#${config.colorScheme.palette.base0C}";

      color7 = "#${config.colorScheme.palette.base05}";
      color15 = "#${config.colorScheme.palette.base07}";

      # Tab colors
      active_tab_foreground = "#${config.colorScheme.palette.base00}";
      active_tab_background = "#${config.colorScheme.palette.base05}";
      inactive_tab_foreground = "#${config.colorScheme.palette.base05}";
      inactive_tab_background = "#${config.colorScheme.palette.base01}";

      # Mark colors
      mark1_foreground = "#${config.colorScheme.palette.base00}";
      mark1_background = "#${config.colorScheme.palette.base08}";
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 20;
  };

  home.packages = with pkgs; [
    # appimage-run
    # anytype
    # blueberry
    # bemoji
    # brightnessctl
    # clipman
    # distrobox
    # eww
    # firefox-devedition
    # file-roller
    # hyprpanel
    # seahorse
    # sushi
    # glib
    # google-chrome
    # gsettings-desktop-schemas
    # graphviz
    # ksnip
    # msty
    # msty-sidecar
    # msty-studio
    # nwg-look
    # pamixer
    # pavucontrol
    # libsForQt5.qtstyleplugins
    # stable.nyxt
    # pcmanfm
    # rose-pine-hyprcursor
    # qt5ct
    # qt6.qtwayland
    # rustdesk
    # socat
    # unrar
    # unzip
    # usbutils
    # v4l-utils
    # remmina
    # slack
    telegram-desktop
    # vivaldi
    # vivaldi-ffmpeg-codecs
    # warp-terminal
    # wl-clipboard
    # wlogout
    # wtype
    # xdg-utils
    # ydotool
    # zip
  ];
}


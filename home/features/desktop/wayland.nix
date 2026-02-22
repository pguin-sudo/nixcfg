{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.wayland;
in
{
  options.features.desktop.wayland.enable = mkEnableOption "wayland extra tools and config";

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      terminal = "${pkgs.kitty}/bin/kitty";
      extraConfig = {
        modi = "drun,run,window";
        show-icons = true;
        display-drun = "Applications";
        display-run = "Run";
        display-window = "Windows";
        drun-display-format = "{name}";
        window-format = "{w} {i} {t}";
      };
    };

    home.packages = with pkgs; [
      slurp
      wl-clipboard
      wtype

      pamixer
      pavucontrol
      playerctl

      brightnessctl
      networkmanagerapplet
      kdePackages.kdeconnect-kde

      mako
      libnotify

      swww

      # Mime & xdg
      xdg-utils
      shared-mime-info

      # Images
      grim
      swappy
      sway-contrib.grimshot
      swayimg

      # For checking keybinds
      wev

      # Hyprland
      pyprland
      wayvnc
    ];

    home.file."Wallpapers" = {
      source = ../../resources/Wallpapers;
      recursive = true;
    };

    services = {
      mako = {
        enable = true;
        settings.default-timeout = 5000;
      };

      swww = {
        enable = true;
      };
    };

    xdg = {
      portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-wlr
        ];
      };

      mimeApps = {
        enable = true;

        defaultApplications = {
          "inode/directory" = [ "org.kde.dolphin.desktop" ];
          "x-scheme-handler/file" = [ "org.kde.dolphin.desktop" ];

          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "x-scheme-handler/about" = [ "firefox.desktop" ];
          "x-scheme-handler/unknown" = [ "firefox.desktop" ];

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

    programs.hyprlock = {
      enable = true;
    };

    # Small fix for home-manager
    dconf.enable = false;

    # Custom wallpaper script
    home.file.".config/hypr/scripts/next-wallpaper.sh" = {
      text = ''
        # Configuration
        WALLPAPER_DIR="$HOME/Wallpapers/catppuccin"
        STATE_FILE="$HOME/.config/hypr/wallpaper_index"
        DISPLAY="eDP-1"  # Change to your monitor, use hyprctl monitors to check

        # Create Wallpapers directory if it doesn't exist
        mkdir -p "$WALLPAPER_DIR"

        # Get list of wallpapers and check if directory is empty
        wallpapers=("$WALLPAPER_DIR"/*)
        if [ ''${#wallpapers[@]} -eq 0 ] || [ ! -f "''${wallpapers [ 0 ]}" ]; then
            echo "Error: No wallpapers found in $WALLPAPER_DIR"
            exit 1
        fi

        total_wallpapers=''${#wallpapers[@]}

        # Read current index or initialize to 0
        if [ -f "$STATE_FILE" ]; then
            current_index=$(cat "$STATE_FILE")
        else
            current_index=0
        fi

        # Calculate next index (cycles back to 0 after last wallpaper)
        next_index=$(( (current_index + 1) % total_wallpapers ))

        # Save the next index for future use
        echo "$next_index" > "$STATE_FILE"

        # Set the wallpaper using swww
        swww img "''${wallpapers[$next_index]}" --transition-type=fade --transition-duration=1

        # Optional: Send notification
        notify-send "Wallpaper Changed" "$(basename "''${wallpapers[$next_index]}")" -t 2000 -i "''${wallpapers[$next_index]}"
      '';
      executable = true;
    };
  };
}

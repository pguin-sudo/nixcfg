{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.hyprland;
in
{
  options.features.desktop.hyprland.enable = mkEnableOption "hyprland config";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;

      xwayland.enable = true;
      settings = {
        xwayland = {
          force_zero_scaling = true;
        };
      };

      settings = {
        monitor = [
          "HEADLESS-2,1920x1200@60,-1920x0,1.5"
        ];

        exec-once = [
          "waybar"
          "swww-daemon"
          "swww restore"
          "wl-clipboard-history -t"
          "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
          "poweralertd"
          "syncthing"
          "sleep 3; qsyncthingtray"
          "kdeconnect-indicator"
          "dbus-update-activation-environment --systemd --all"

          # Virtual display
          "hyprctl output create headless"
          "wayvnc -o HEADLESS-2 0.0.0.0"
        ];

        env = [
          "XCURSOR_SIZE,24"
          "NIXOS_OZONE_WL,1"
          "GTK_THEME,Nightfox-Dark"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "ELECTRON_EXTRA_FLAGS,--force-device-scale-factor=1.5"
          "XDG_MENU_PREFIX,plasma-"
        ];

        input = {
          kb_layout = "us,ru";
          kb_options = "grp:win_space_toggle";
          follow_mouse = 1;

          repeat_delay = 200;
          repeat_rate = 40;

          touchpad = {
            natural_scroll = true;
            disable_while_typing = 0;
            tap-to-click = 1;
          };

          sensitivity = 0;
          accel_profile = "linear";
        };

        general = {
          gaps_in = 3;
          gaps_out = 5;
          border_size = 2;
          layout = "dwindle";
        };

        decoration = {
          rounding = 8;

          shadow = {
            enabled = true;
            range = 60;
            offset = "1 2";
            render_power = 3;
            scale = 0.97;
          };

          blur = {
            enabled = true;
            size = 3;
            passes = 3;
            noise = 0.0117;
            contrast = 1.0;
            brightness = 1.0;
            vibrancy = 0.1696;
            vibrancy_darkness = 0.0;
            special = true;
            new_optimizations = true;
          };

          dim_special = 0.2;
          active_opacity = 0.95;
          inactive_opacity = 0.85;
          fullscreen_opacity = 1.0;
        };

        animations = {
          enabled = true;

          bezier = [
            "linear, 0, 0, 1, 1"
            "md3_standard, 0.2, 0, 0, 1"
            "md3_decel, 0.05, 0.7, 0.1, 1"
            "md3_accel, 0.3, 0, 0.8, 0.15"
            "overshot, 0.05, 0.9, 0.1, 1.1"
            "crazyshot, 0.1, 1.5, 0.76, 0.92"
            "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
            "menu_decel, 0.1, 1, 0, 1"
            "menu_accel, 0.38, 0.04, 1, 0.07"
            "easeInOutCirc, 0.85, 0, 0.15, 1"
            "easeOutCirc, 0, 0.55, 0.45, 1"
            "easeOutExpo, 0.16, 1, 0.3, 1"
            "softAcDecel, 0.26, 0.26, 0.15, 1"
            "md2, 0.4, 0, 0.2, 1"
          ];

          animation = [
            "windows, 1, 6, md3_decel, popin 60%"
            "windowsIn, 1, 6, md3_decel, popin 60%"
            "windowsOut, 1, 6, md3_accel, popin 60%"
            "border, 1, 20, default"
            "fade, 1, 6, md3_decel"
            "layersIn, 1, 6, menu_decel, slide"
            "layersOut, 1, 3.2, menu_accel"
            "fadeLayersIn, 1, 4, menu_decel"
            "fadeLayersOut, 1, 9, menu_accel"
            "workspaces, 1, 14, menu_decel, slide"
            "specialWorkspace, 1, 6, md3_decel, slidevert"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
          special_scale_factor = 0.8;
        };

        master = { };

        gestures = {
          gesture = "3, horizontal, workspace";
        };

        misc = {
          disable_hyprland_logo = true;
          force_default_wallpaper = 0;
          animate_manual_resizes = true;
          animate_mouse_windowdragging = true;
          enable_swallow = true;
          focus_on_activate = true;
          vfr = true;
        };

        "$mainMod" = "SUPER";
        "$terminal" = "kitty";
        "$explorer" = "dolphin";
        "$browser" = "firefox";
        "$top" = "btop";
        "$editor" = "nvim";
        "$ide" = "zeditor";

        bind = [
          # Power
          #"$mainMod, Escape, exec, wlogout -p layer-shell"
          "$mainMod Shift, Delete, exec, systemctl suspend"
          "$mainMod, Delete, exec, shutdown now"
          "$mainMod Ctrl, Delete, exec, reboot"
          #"$mainMod, L, exec, hyprlock"

          # Windows
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          "$mainMod, F1, exec, $HOME/.config/hypr/scripts/keybind.sh"
          "$mainMod, Q, killactive"
          "$mainMod, F, fullscreen"
          "$mainMod, V, togglesplit"
          "$mainMod, j, movefocus, d"
          "$mainMod, K, movefocus, u"
          "$mainMod, H, movefocus, l"
          "$mainMod, L, movefocus, r"
          "$mainMod Shift, H, movewindow, l"
          "$mainMod Shift, L, movewindow, r"
          "$mainMod Shift, k, movewindow, u"
          "$mainMod Shift, J, movewindow, d"
          "$mainMod Shift, Q, exit"
          "$mainMod, W, togglefloating"
          "$mainMod Shift, P, pin"

          # System (Overlays)
          "$mainMod, P, exec, grimshot savecopy area - | swappy -f - -o ~/Photos/screenshots/screenshot-$(date +'%d-%m-%Y_%H%M').png"

          # Workspaces
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          #"$mainMod, 0, workspace, 10"
          "$mainMod, code:49, workspace, 10"
          "$mainMod Shift, 1, movetoworkspacesilent, 1"
          "$mainMod Shift, 2, movetoworkspacesilent, 2"
          "$mainMod Shift, 3, movetoworkspacesilent, 3"
          "$mainMod Shift, 4, movetoworkspacesilent, 4"
          "$mainMod Shift, 5, movetoworkspacesilent, 5"
          "$mainMod Shift, 6, movetoworkspacesilent, 6"
          "$mainMod Shift, 7, movetoworkspacesilent, 7"
          "$mainMod Shift, 8, movetoworkspacesilent, 8"
          "$mainMod Shift, 9, movetoworkspacesilent, 9"
          #"$mainMod Shift, 0, movetoworkspacesilent, 10"
          "$mainMod Shift, code:49, movetoworkspacesilent, 10"
          "Alt, Tab, cyclenext"

          # Special workspaces
          "$mainMod, S, togglespecialworkspace"
          "$mainMod Shift, S, movetoworkspace, special"

          # Scripts
          "$mainMod Shift, W, exec, sh ~/.config/hypr/scripts/next-wallpaper.sh"

          # Apps
          "$mainMod, T, exec, $terminal"
          "$mainMod Shift, T, exec, Telegram"
          "$mainMod, B, exec, $browser"
          "$mainMod Shift, B, exec, $browser -P I2P"
          "$mainMod, E, exec, $explorer"
          "$mainMod, A, exec, rofi -show drun"
          "$mainMod, Z, exec, $ide"

          "Ctrl Shift, Escape, exec, $terminal $top"
          "$mainMod, N, exec, $terminal -e zsh -ic \"notepad; exit\""
          # Notebook keys
          "SUPER SHIFT, code:201, exec, $terminal $editor ~/nixcfg"
          "SUPER, code:60, exec, sudo -E howdy test"
          ", code:156, exec, $terminal -e zsh -ic \"rebuild\""
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        binde = [
          "$mainMod, left, resizeactive, -40 0"
          "$mainMod, right, resizeactive, 40 0"
          "$mainMod, up, resizeactive, 0 -40"
          "$mainMod, down, resizeactive, 0 40"
          ", XF86AudioMute, exec, pamixer -t"
          ", XF86AudioLowerVolume, exec, pamixer -d 2"
          ", XF86AudioRaiseVolume, exec, pamixer -i 2"
          ", XF86MonBrightnessUp, exec, brightnessctl set 1%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set 1%-"
          ", XF86AudioMicMute, exec, notify-send \"Mic mute\""
        ];

        windowrulev2 = [
          "workspace 1, class:^(firefox)$"
          "workspace special, class:^(org.telegram.desktop)$"
          "workspace special, class:^(vesktop)$"
        ];

        workspace = [
          "1, monitor:HDMI-A-1, default:true"
          "2, monitor:HDMI-A-1"
          "3, monitor:HDMI-A-1"
          "4, monitor:HDMI-A-1"
          "5, monitor:HDMI-A-1"
          "6, monitor:HDMI-A-1"
          "7, monitor:HDMI-A-1"
          "8, monitor:HDMI-A-1"
          "9, monitor:HDMI-A-1"
          #"10, monitor:HDMI-A-1"

          "10, monitor:HEADLESS-2, default:false"
        ];
      };
    };

    # Scratchpad
    home.file.".config/hypr/pyprland.toml".text = ''
      [pyprland]
          # pypr has a lot of plugins, but this is just a basic example config
          # https://hyprland-community.github.io/pyprland/Plugins.html
          plugins = [ "scratchpads" ]

      [pyprland.variables]
          term_with_klass = "kitty --class"

      [scratchpads.console]
          # This is a drop-down terminal configuration
          animation = "fromTop"
          class     = "console-dropdown"
          command   = "[term_with_class] console-dropdown"
          max_size  = "90% 100%"
          size      = "80% 80%"
    '';

    home.packages = with pkgs; [
      pyprland

      wayvnc
    ];

    programs.hyprlock = {
      enable = true;
    };

    # Small fix for home-manager
    dconf.enable = false;

    # Custom wallpaper script
    home.file.".config/hypr/scripts/next-wallpaper.sh".source = ./scripts/next-wallpaper.sh;
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprland;
in {
  options.features.desktop.hyprland.enable = mkEnableOption "hyprland config";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true; # Better systemd integration
      xwayland.enable = true; # Moved to top-level option

      settings = {
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
        ];

        env = [
          "XCURSOR_SIZE,24"
          "NIXOS_OZONE_WL,1"
          "GTK_THEME,Nightfox-Dark"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "ELECTRON_EXTRA_FLAGS,--force-device-scale-factor=1.5"
        ];

        input = {
          kb_layout = "us,ru";
          kb_options = "grp:win_space_toggle";
          follow_mouse = 1;

          repeat_delay = 200;
          repeat_rate = 40;

          touchpad = {
            natural_scroll = true;
            disable_while_typing = 1;
            tap-to-click = 1;
          };

          sensitivity = 0.25;
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

        master = {};

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

        bind = [
          "$mainMod, Escape, exec, wlogout -p layer-shell"
          "$mainMod, Backspace, exec, systemctl suspend"
          "$mainMod, Delete, exec, shutdown now"

          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          "$mainMod, F1, exec, $HOME/.config/hypr/scripts/keybind.sh"
          "$mainMod, Q, killactive"
          "$mainMod, B, exec, firefox"
          "$mainMod, F, fullscreen"
          "$mainMod, V, togglesplit"
          "$mainMod, j, movefocus, d"
          "$mainMod, k, movefocus, u"
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, l, movewindow, r"
          "$mainMod SHIFT, k, movewindow, u"
          "$mainMod SHIFT, j, movewindow, d"
          "$mainMod, t, exec, kitty"
          "$mainMod SHIFT, Q, exit"
          "$mainMod, E, exec, dolphin"
          "$mainMod, A, exec, rofi -show drun"
          "ALTCTRL, DELETE, exec, btop"
          "$mainMod, W, togglefloating"

          "$mainMod, PrtScr, exec, hyprctl keyword animation 'fadeOut,0,0,default'; grimshot --notify copy active; hyprctl keyword animation 'fadeOut,1,4,default'"
          "$mainMod, P, exec, grimshot savecopy area - | swappy -f - -o ~/Photos/screenshots/screenshot-$(date +'%d-%m-%Y_%H%M').png"

          "$mainMod SHIFT, R, exec, wf-recorder -a -f ~/Video/recording.mkv & notify-send 'Recordering Started' -i -u -A '^C ,stop' -t 0 -i ~/icons/rec-button.png"
          "$mainMod, A, exec, ~/.config/hypr/scripts/screenHz.sh"
          "$mainMod SHIFT, RETURN, layoutmsg, swapwithmaster"
          "$mainMod SHIFT, W, exec, sh ~/.config/hypr/scripts/next-wallpaper.sh"

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
          "$mainMod, 0, workspace, 10"
          "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
          "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
          "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
          "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
          "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
          "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
          "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
          "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
          "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
          "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
          "ALT, Tab, cyclenext"

          # Special workspaces
          "$mainMod, S, togglespecialworkspace"
          "$mainMod Shift, S, movetoworkspace, special"

          "$mainMod SHIFT, T, exec, Telegram"
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
          ", XF86AudioMute, exec, $HOME/.config/hypr/scripts/volume mute"
          ", XF86AudioLowerVolume, exec, $HOME/.config/hypr/scripts/volume down"
          ", XF86AudioRaiseVolume, exec, $HOME/.config/hypr/scripts/volume up"
          ", XF86MonBrightnessUp, exec, $HOME/.config/hypr/scripts/brightness up"
          ", XF86MonBrightnessDown, exec, $HOME/.config/hypr/scripts/brightness down"
        ];

        windowrulev2 = [
          "workspace 1, class:^(firefox)$"
          "workspace special, class:^(org.telegram.desktop)$"
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
    ];

    # Custom wallpaper script
    home.file.".config/hypr/scripts/next-wallpaper.sh".source = ./scripts/next-wallpaper.sh;
  };
}

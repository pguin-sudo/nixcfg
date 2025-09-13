{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprland;
in {
  options.features.desktop.hyprland.enable = 
    mkEnableOption "Hyprland related stuff";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        xwayland = {
          force_zero_scaling = true;
        };

        exec-once = [
          "hyprpanel"
          "hyprpaper"
          "hyprpaper-random"
          "hypridle"
          "wl-paste --type text --watch cliphist store" # Stores only text data
          "wl-paste --type image --watch cliphist store" # Stores only image data "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
          "xwaylandvideobridge"
        ];

        env = [
          "XCURSOR_SIZE,32"
          "HYPRCURSOR_THEME,Bibata-Modern-Ice"
          "WLR_NO_HARDWARE_CURSORS,1"
          "GTK_THEME,Dracula"
        ];

        input = {
          kb_layout = "de,us";
          kb_variant = "";
          kb_model = "";
          kb_rules = "";
          kb_options = "ctrl:nocaps";
          follow_mouse = 1;
        };

        general = {
          gaps_in = 5;
          gaps_out = 5;
          border_size = 1;
          # Keeping the existing active border as requested
          "col.active_border" = "rgba(9742b5ee) rgba(9742b5ee) 45deg";
          "col.inactive_border" = "rgba(${config.colorScheme.palette.base03}aa)";
          layout = "dwindle";
        };

        decoration = {
          shadow = {
            enabled = true;
            range = 60;
            render_power = 3;
            color = "rgba(${config.colorScheme.palette.base00}66)";
            offset = "1 2";
            scale = 0.97;
          };
          rounding = 8;
          blur = {
            enabled = true;
            size = 3;
            passes = 3;
          };
          active_opacity = 0.9;
          inactive_opacity = 0.5;
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master = {
          new_status = "master";
        };

        gestures = {
          workspace_swipe = false;
        };

        device = [
          {
            name = "epic-mouse-v1";
            sensitivity = -0.5;
          }
          {
            name = "zsa-technology-labs-moonlander-mark-i";
            kb_layout = "us";
          }
          {
            name = "keychron-keychron-k7";
            kb_layout = "us";
          }
        ];
        windowrule = [
          "float, class:file_progress"
          "float, class:confirm"
          "float, class:dialog"
          "float, class:download"
          "float, class:notification"
          "float, class:error"
          "float, class:splash"
          "float, class:confirmreset"
          "float, title:Open File"
          "float, title:branchdialog"
          "float, class:pavucontrol-qt"
          "float, class:pavucontrol"
          "fullscreen, class:wlogout"
          "float, title:wlogout"
          "fullscreen, title:wlogout"
          "float, class:mpv"
          "idleinhibit focus, class:mpv"
          "opacity 1.0 override, class:mpv"
          "float, title:^(Media viewer)$"
          "float, title:^(Volume Control)$"
          "float, title:^(Picture-in-Picture)$"
          "float,title:^(floating-pomodoro)$"
          "size 250 50, title:^(floating-pomodoro)$"
          "move 12 100%-150,title:^(floating-pomodoro)$"
          "pin,title:^(floating-pomodoro)$"
          "float, initialTitle:.*streamlabs.com.*"
          "pin, initialTitle:.*streamlabs.com.*"
          "size 800 400, initialTitle:.*streamlabs.com.*"
          "move 100%-820 102, initialTitle:.*alert-box.*"
          "move 100%-820 512, initialTitle:.*chat-box.*"
          "opacity 0.5 override, initialTitle:.*streamlabs.com.*"
          "idleinhibit focus, initialTitle:.*streamlabs.com.*"
          "noanim, initialTitle:.*streamlabs.com.*"
          "noborder, initialTitle:.*streamlabs.com.*"
          "noshadow, initialTitle:.*streamlabs.com.*"
          "noblur, initialTitle:.*streamlabs.com.*"
          "opacity 0.0 override, class:^(xwaylandvideobridge)$"
          "noanim, class:^(xwaylandvideobridge)$"
          "noinitialfocus, class:^(xwaylandvideobridge)$"
          "maxsize 1 1, class:^(xwaylandvideobridge)$"
          "noblur, class:^(xwaylandvideobridge)$"
          "nofocus, class:^(xwaylandvideobridge)$"
        ];
        "$mainMod" = "SUPER";
        "$terminal" = "kitty";

        bind = [
          "$mainMod, return, exec, $terminal nu -c zellij-ps"
          # "$mainMod, t, exec, warp-terminal"
          "$mainMod, t, exec, $terminal -e nu -c 'nitch; exec nu'"
          "$mainMod SHIFT, t, exec, launch-timer"
          "$mainMod, n, exec, $terminal -e nvim"
          "$mainMod, z, exec, uwsm app -- zeditor"
          "$mainMod, o, exec, hyprctl setprop activewindow opaque toggle"
          "$mainMod, r, exec, hyprctl dispatch focuswindow \"initialtitle:.*alert-box.*\" && hyprctl dispatch moveactive exact 4300 102 && hyprctl dispatch focuswindow \"initialtitle:.*chat-box.*\" && hyprctl dispatch moveactive exact 4300 512"
          "$mainMod, b, exec, uwsm app -- thunar"
          "$mainMod SHIFT, B, exec, uwsm app -- vivaldi"
          "$mainMod, Escape, exec, uwsm app -- wlogout -p layer-shell"
          "$mainMod, Space, togglefloating"
          "$mainMod, q, killactive"
          "$mainMod, M, exit"
          "$mainMod, F, fullscreen"
          "$mainMod SHIFT, V, togglefloating"
          "$mainMod, D, exec, uwsm app -- rofi -show drun -run-command \"uwsm app -- {cmd}\""
          "$mainMod, V, exec, uwsm app -- cliphist list | rofi -dmenu | cliphist decode | wl-copy"
          "$mainMod SHIFT, S, exec, uwsm app -- rofi -show emoji"
          "$mainMod, P, exec, uwsm app -- rofi-pass"
          "$mainMod SHIFT, P, pseudo"
          "$mainMod, J, togglesplit"
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"
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
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
  };
}


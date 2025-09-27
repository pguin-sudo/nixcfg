{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.features.desktop.hyprland;
in
{
  options.features.desktop.hyprland.enable = mkEnableOption "hyprland config";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true; # Better systemd integration
      xwayland.enable = true; # Moved to top-level option

      settings = {
        # Monitor lines must be strings, not a list of strings
        monitor = [
          "eDP-1,1366x768@60.06,0x0,1"
        ];

        workspace = [
          # "1, monitor:DP-1, default:true"
          # "2, monitor:DP-1"
        ];

        exec-once = [
          "waybar"
          "hyprpaper"
          "hypridle"
          "wl-clipboard-history -t"
          "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
          "poweralertd"
          "syncthing"
          "sleep 3; qsyncthingtray"
          "kdeconnect-indicator"
          # Critical: Fixed typo and use systemd environment import
          "dbus-update-activation-environment --systemd --all"
        ];

        # Environment variables as Nix attributes, not strings
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
          "col.active_border" = "rgba(5faaffee) rgba(5faaffee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };

        decoration = {
          rounding = 8;
          shadow = {
            enabled = true;
            color = "rgba(1E202966)";
            range = 60;
            offset = "1 2";
            render_power = 3;
            scale = 0.97;
          };
          blur = {
            enabled = true;
            size = 3;
            passes = 3;
          };
          active_opacity = 1;
          inactive_opacity = 0.95;
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

        master = { };

        gestures = {
          gesture = "3, horizontal, workspace";
        };

        misc = {
          vfr = true;
        };

        "$mainMod" = "SUPER";

        bind = [
          "$mainMod, Escape, exec, wlogout -p layer-shell"
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
          "$mainMod, E, exec, nautilus"
          "$mainMod, A, exec, ~/.config/rofi/launchers/type-6/launcher.sh"
          "ALTCTRL, DELETE, exec, htop"
          "$mainMod, W, togglefloating"
          "$mainMod SHIFT, S, exec, hyprctl keyword animation 'fadeOut,0,0,default'; grimshot --notify copy active; hyprctl keyword animation 'fadeOut,1,4,default'"
          "$mainMod SHIFT, R, exec, wf-recorder -a -f ~/Video/recording.mkv & notify-send 'Recordering Started' -i -u -A '^C ,stop' -t 0 -i ~/icons/rec-button.png"
          "$mainMod SHIFT, E, exec, rofimoji"
          "$mainMod, A, exec, ~/.config/hypr/scripts/screenHz.sh"
          "$mainMod SHIFT, RETURN, layoutmsg, swapwithmaster"
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

          "$mainMod SHIFT, T, exec, telegram-desktop"
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
          # Add your window rules here
        ];
      };
    };
  };
}

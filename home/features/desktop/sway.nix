{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.sway;
  mod = "Mod4";
in {
  options.features.desktop.sway.enable = mkEnableOption "sway config";

  config = mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;

      systemd.enable = true;
      wrapperFeatures = {gtk = true;};

      config = {
        modifier = mod;

        bars = [
          {
            position = "top";
          }
        ];

        # Startup commands
        startup = [
          #{command = "waybar";}
          {command = "hyprpaper";}
          {command = "hypridle";}
          {command = "wl-clipboard-history -t";}
          {command = "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\"";}
          {command = "poweralertd";}
          {command = "syncthing";}
          {command = "sleep 3; qsyncthingtray";}
          {command = "kdeconnect-indicator";}
          {command = "dbus-update-activation-environment --systemd --all";}
        ];

        # Input configuration
        input = {
          "type:keyboard" = {
            xkb_layout = "us,ru";
            xkb_options = "grp:win_space_toggle";
          };
          "type:touchpad" = {
            natural_scroll = "enabled";
            tap = "enabled";
          };
        };

        # General appearance
        gaps = {
          inner = 3;
          outer = 5;
          smartGaps = true;
        };
        window = {
          border = 2;
          hideEdgeBorders = "smart";
          titlebar = false;
        };

        focus = {
          followMouse = true;
        };

        # Key bindings
        keybindings = lib.attrsets.mergeAttrsList [
          (lib.attrsets.mergeAttrsList (map (num: let
            ws = toString num;
          in {
            "${mod}+${ws}" = "workspace ${ws}";
            "${mod}+Shift+${ws}" = "move container to workspace ${ws}";
          }) [1 2 3 4 5 6 7 8 9 0]))

          (lib.attrsets.concatMapAttrs (key: direction: {
              "${mod}+${key}" = "focus ${direction}";
              "${mod}+Shift+${key}" = "move ${direction}";
            }) {
              h = "left";
              j = "down";
              k = "up";
              l = "right";
            })

          {
            # Basic applications
            "${mod}+T" = "exec ${pkgs.kitty}/bin/kitty";
            "${mod}+B" = "exec firefox";
            "${mod}+E" = "exec ${pkgs.kdePackages.dolphin}/bin/dolphin";
            "${mod}+A" = "exec rofi -show drun";

            # Window management
            "${mod}+Q" = "kill";
            "${mod}+F" = "fullscreen toggle";
            "${mod}+V" = "split toggle";
            "${mod}+W" = "floating toggle";
            "${mod}+Shift+Return" = "focus parent";

            # System
            "${mod}+Escape" = "exec ${pkgs.wlogout}/bin/wlogout -p layer-shell";
            "${mod}+Shift+Q" = "exit";
            "${mod}+R" = "reload";

            # Screenshots
            "${mod}+Print" = "exec grimshot copy active";
            "${mod}+Shift+s" = "exec grimshot savecopy area - | ${pkgs.swappy}/bin/swappy -f - -o ~/Photos/screenshots/screenshot-$(date +'%d-%m-%Y_%H%M').png";

            # Screen recording (requires wf-recorder)
            "${mod}+Shift+R" = "exec wf-recorder -a -f ~/Video/recording.mkv & notify-send 'Recording Started' -i -u -A '^C ,stop' -t 0";

            # Utilities
            "Alt+Ctrl+Delete" = "exec ${pkgs.btop}/bin/btop";
            "${mod}+Shift+E" = "exec ${pkgs.rofimoji}/bin/rofimoji";
            "${mod}+Shift+T" = "exec Telegram";

            # Media keys
            "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +10%";
            "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";

            # Workspace navigation
            "Alt+Tab" = "workspace next";
            "Alt+Shift+Tab" = "workspace prev";
          }
        ];

        workspaceAutoBackAndForth = true;
      };

      # Extra config for features not available in main config
      extraConfig = ''
        # Blur effects (requires swayfx)
        # corner_radius 8
        # blur enable
        # blur_size 3
        # blur_passes 3

        # Opacity
        # for_window [class=".*"] opacity 0.95
        # for_window [class=".*" focus] opacity 1.0

        # Window borders (colors)
        client.focused #5faaff #5faaff #ffffff #5faaff
        client.focused_inactive #595959 #595959 #ffffff #595959
        client.unfocused #595959 #595959 #ffffff #595959
      '';
    };
  };
}

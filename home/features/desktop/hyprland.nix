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
      configType = "hyprlang";

      xwayland.enable = true;

      settings = {
        xwayland = {
          force_zero_scaling = true;
        };

        # Force every output to scale 1 (no fractional 1.5). Empty name = all
        # monitors, preferred resolution, auto position, scale 1.
        monitor = [
          ",preferred,auto,1"
        ];

        exec-once = [
          "noctalia"
        ];

        env = [
          "XCURSOR_THEME,Bibata-Modern-Ice"
          "XCURSOR_SIZE,24"
          "NIXOS_OZONE_WL,1"
          "GTK_THEME,Nightfox-Dark"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "ELECTRON_EXTRA_FLAGS,--force-device-scale-factor=1"
          "QT_QPA_PLATFORMTHEME,qt6ct"
          "QT_QPA_PLATFORMTHEME_QT6,qt6ct"
          "EDITOR,$editor"
          "VISUAL,$ide"
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
            "layersIn, 1, 6, menu_decel"
            "layersOut, 1, 1, menu_accel"
            "fadeLayersIn, 1, 4, menu_decel"
            "fadeLayersOut, 1, 1, menu_accel"
            "workspaces, 1, 14, menu_decel, slide"
            "specialWorkspace, 1, 6, md3_decel, slidevert"
          ];
        };

        dwindle = {
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
        };

        "$mainMod" = "SUPER";
        "$terminal" = "kitty";
        "$explorer" = "yazi";
        # Per-host browser binary (zen-beta on lambda, firefox on delta) — the
        # old literal "zen-browser" was not a real binary name.
        "$browser" = config.home.sessionVariables.BROWSER or "firefox";
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
          "$mainMod, P, exec, noctalia msg screenshot-region"

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
          "$mainMod, code:49, workspace, -1"
          "$mainMod Shift, 1, movetoworkspacesilent, 1"
          "$mainMod Shift, 2, movetoworkspacesilent, 2"
          "$mainMod Shift, 3, movetoworkspacesilent, 3"
          "$mainMod Shift, 4, movetoworkspacesilent, 4"
          "$mainMod Shift, 5, movetoworkspacesilent, 5"
          "$mainMod Shift, 6, movetoworkspacesilent, 6"
          "$mainMod Shift, 7, movetoworkspacesilent, 7"
          "$mainMod Shift, 8, movetoworkspacesilent, 8"
          "$mainMod Shift, 9, movetoworkspacesilent, 9"
          "$mainMod Shift, 0, movetoworkspacesilent, 10"
          "$mainMod Shift, code:49, movetoworkspacesilent, -1"
          "Alt, Tab, cyclenext"

          # Special workspaces
          "$mainMod, S, togglespecialworkspace"
          "$mainMod Shift, S, movetoworkspace, special"

          # Scripts
          "$mainMod, U, exec, bash ~/.config/hypr/scripts/rgb_sync.sh"

          # Noctalia panels (wallpaper is Noctalia-managed, see noctalia.nix)
          "$mainMod Shift, W, exec, noctalia msg wallpaper-next"
          "$mainMod, V, exec, noctalia msg panel-toggle clipboard"
          "$mainMod, A, exec, noctalia msg panel-toggle launcher"

          # Apps
          "$mainMod, T, exec, $terminal"
          "$mainMod Shift, T, exec, Telegram"
          "$mainMod, B, exec, $browser"
          "$mainMod Shift, B, exec, $browser -P I2P"
          "$mainMod, E, exec, kitty -e $explorer"
          "$mainMod, Z, exec, $ide"

          "Ctrl Shift, Escape, exec, $terminal $top"
          "$mainMod, N, exec, $terminal -e zsh -ic \"notepad; exit\""
          "$mainMod, R, exec, bash ~/.config/hypr/scripts/rotate-screen.sh"

          # Laptop keys
          "SUPER SHIFT, code:201, exec, bash ~/.config/hypr/scripts/random-sound.sh"
          # "SUPER, code:60, exec, sudo -E howdy test" # Howdy disabled
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
          ", XF86AudioPlay, exec, noctalia msg media toggle"
          ", XF86AudioPause, exec, noctalia msg media toggle"
          ", XF86AudioNext, exec, noctalia msg media next"
          ", XF86AudioPrev, exec, noctalia msg media previous"
          ", XF86AudioMute, exec, noctalia msg volume-mute"
          ", XF86AudioLowerVolume, exec, noctalia msg volume-down 2"
          ", XF86AudioRaiseVolume, exec, noctalia msg volume-up 2"
          ", XF86MonBrightnessUp, exec, noctalia msg brightness-up"
          ", XF86MonBrightnessDown, exec, noctalia msg brightness-down"
          ", XF86AudioMicMute, exec, noctalia msg mic-mute"
        ];

        bindl = [
          ", xf86poweroff, exec, noctalia msg session lock"
        ];

        # windowrulev2 is a hard error on Hyprland >= 0.55 ("windowrulev2 is
        # deprecated"). New syntax: "match:<field> <value>" selectors mixed
        # with "<effect> <value>" (boolean effects need an explicit on/1/true),
        # all matches+effects sharing one condition can live in a single line.
        # bordersize was also renamed to border_size.
        windowrule = [
          "match:class ^(org.telegram.desktop)$, workspace special"
          "match:class ^(discord)$, workspace special"
          "match:class ^(vesktop)$, workspace special"
          "match:class ^(kitty)$, match:title ^(termfilechooser)$, float on, center on, size 800 600, border_size 10"
          "match:title .*Picture-in-Picture.*, float on, pin on, size 480 270, move 75% 10%"
        ];

        # Frosted-glass Noctalia bar: blur whatever is behind its (low-opacity)
        # layer. Same 0.55 match:/effect syntax as windowrule; layer matches on
        # namespace (live name: noctalia-bar-default).
        layerrule = [
          "match:namespace ^(noctalia-bar-.+)$, blur on, ignore_alpha 0.2"
        ];

      };

      # Source the runtime layout files nwg-displays writes (per-monitor
      # resolution/scale + workspace-to-monitor assignments). Sourced AFTER the
      # settings above, so the GUI's choices override the ",preferred,auto,1"
      # fallback. Empty stubs are created on activation (see home.activation
      # below) so these sources never error before nwg-displays has run once.
      extraConfig = ''
        source = ~/.config/hypr/monitors.conf
        source = ~/.config/hypr/workspaces.conf

        # FIX CURSOR FLICKERING
        cursor:no_hardware_cursors = 1
      '';
    };

    # Make sure the nwg-displays output files exist so Hyprland's `source` above
    # succeeds on a fresh machine; never clobber real content nwg-displays wrote.
    home.activation.nwgDisplaysStubs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "$HOME/.config/hypr"
      for f in monitors.conf workspaces.conf; do
        [ -e "$HOME/.config/hypr/$f" ] || run touch "$HOME/.config/hypr/$f"
      done
    '';

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

    home.file.".config/hypr/scripts/rotate-screen.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Hyprland script: Cycle monitor rotation 0→1→2→3→0 (90° steps clockwise)
        # Each key press rotates the FOCUSED monitor + perfectly syncs mouse/touch/tablet input
        # Uses per-monitor cache so state survives reboots and works with multi-monitor setups

        CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/hyprland_rotations"
        mkdir -p "$CACHE_DIR"

        # Get currently focused monitor
        MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

        if [ -z "$MONITOR" ]; then
          echo "Error: No focused monitor found!"
          notify-send "Hyprland Rotate" "No focused monitor found!" --icon=display
          exit 1
        fi

        # Safe filename for cache (handles eDP-1, HDMI-A-1, etc.)
        CACHE_FILE="''${CACHE_DIR}/''${MONITOR//[^a-zA-Z0-9]/_}.rot"

        # Read current rotation (default 0 if no cache)
        if [ -f "$CACHE_FILE" ]; then
          CURRENT=$(cat "$CACHE_FILE")
        else
          CURRENT=0
        fi

        # Cycle: 0 → 1 → 2 → 3 → 0
        NEW=$(( (CURRENT + 1) % 4 ))

        echo "Rotating $MONITOR: $CURRENT → $NEW (90° × $NEW)"

        # === Apply rotation ===
        hyprctl keyword monitor ''${MONITOR},preferred,auto,1,transform,''${NEW}

        # === Sync mouse/touch/tablet input (feels natural again) ===
        #hyprctl keyword input:touchdevice:transform "''${NEW}"
        #hyprctl keyword input:tablet:transform "''${NEW}"

        # Save new state
        echo "$NEW" > "$CACHE_FILE"

        # Nice feedback
        DEG=$((NEW * 90))
        notify-send "Hyprland Rotate" "Monitor: $MONITOR\nRotation: ''${DEG}° (transform ''${NEW})" --icon=display

        echo "✅ Done! Press the key again to cycle to next rotation."
      '';
    };

    home.file.".config/hypr/scripts/virtmon.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/sh

        # VirtMon script v1.0
        # Script created by Linux Renaissance
        # https://www.youtube.com/@LinuxRenaissance
        # https://github.com/LinuxRenaissance
        # Bring your feedback to our Matrix room
        #   https://matrix.to/#/#lr:fosshq.org
        # This script is MIT licensed,
        # Feel free to offer meaningful PR.
        #
        # Make sure you configure your headless in hyprland.conf in advance
        # Example config:
        # monitor=HEADLESS-66,1280x1024@60,2560x450,1.333333

        # === FIRST WE REMOVE ALL HEADLESS MONITORS ===
        for MON in $(hyprctl monitors | grep HEADLESS | awk '{print $2}'); do
          echo "[wayvnc] Removing $MON..."
          hyprctl output remove "$MON"
        done

        # === YOU SHOULD EDIT THESE ===
        VIRTUAL_MONITOR="HEADLESS-66"
        VIRTUAL_WORKSPACE=-1
        REAL_MONITOR="HDMI-A-1"

        # === CLEANUP FUNCTION ===
        cleanup() {
          echo "\n[wayvnc] Cleaning up..."
          hyprctl dispatch moveworkspacetomonitor $VIRTUAL_WORKSPACE $REAL_MONITOR
          hyprctl dispatch focusmonitor "$REAL_MONITOR"
          pkill wayvnc
          echo "[wayvnc] Done."
          exit 0
        }

        # === TRAP EXIT FOR CLEANUP ===
        trap cleanup INT TERM EXIT

        # === NOW WE CREATE YOUR HEADLESS ===
          echo "[wayvnc] Creating $VIRTUAL_MONITOR..."
          hyprctl output create headless $VIRTUAL_MONITOR
          sleep 0.5

        # === ASSIGN WORKSPACE AND ACTIVATE IT ===
        echo "[wayvnc] Moving workspace $VIRTUAL_WORKSPACE to $VIRTUAL_MONITOR..."
        hyprctl dispatch moveworkspacetomonitor $VIRTUAL_WORKSPACE $VIRTUAL_MONITOR
        sleep 0.2
        hyprctl dispatch workspace $VIRTUAL_WORKSPACE
        sleep 0.2

        # === RETURN FOCUS TO YOUR REAL MONITOR SO YOU DON'T GET STUCK ON DELETED ONE ===
        hyprctl dispatch focusmonitor "$REAL_MONITOR"

        # === FINALLY START WayVNC ===
        echo "[wayvnc] Starting WayVNC on $VIRTUAL_MONITOR..."
        wayvnc 0.0.0.0 5900 "$VIRTUAL_MONITOR"
      '';
    };

    home.packages = with pkgs; [
      bibata-cursors
    ];
  };
}

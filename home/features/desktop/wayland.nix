{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.wayland;
in {
  options.features.desktop.wayland.enable = mkEnableOption "wayland extra tools and config";

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 34;
          margin = "0px 0px 0px 0px";
          spacing = 3;

          modules-left = ["hyprland/workspaces"];
          modules-center = ["mpris"];
          modules-right = ["cpu" "memory" "network" "pulseaudio" "backlight" "battery" "tray" "clock"];

          "hyprland/workspaces" = {
            format = "{icon}";
            all-outputs = true;
            on-click = "activate";
            format-icons = {
              active = "󰮯";
              default = "󰍹";
              urgent = "󰈸";
            };
          };

          "tray" = {
            spacing = 6;
            icon-size = 16;
          };

          "clock" = {
            format = "{:%H:%M}";
            format-alt = "{:%d/%m}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt-click = "click-right";
          };

          "cpu" = {
            interval = 5;
            format = "󰻠 {usage}%";
            format-alt = "󰻠 {avg_frequency} GHz";
            max-length = 15;
            tooltip = false;
          };

          "memory" = {
            interval = 5;
            format = "󰍛 {percentage}%";
            format-alt = "󰍛 {used:0.1f}G";
            max-length = 15;
            tooltip = false;
          };

          "backlight" = {
            device = "intel_backlight";
            format = "{icon} {percent}%";
            format-icons = ["󰃞" "󰃟" "󰃠"];
            on-scroll-up = "brightnessctl set 2%+";
            on-scroll-down = "brightnessctl set 2%-";
            tooltip-format = "Brightness: {percent}%";
          };

          "network" = {
            format-wifi = "󰖩 {signalStrength}%";
            format-ethernet = "󰈀";
            format-disconnected = "󰖪";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            format-linked = "󰈀 {ifname} (No IP)";
            max-length = 20;
          };

          "pulseaudio" = {
            format = "{icon} {volume}%";
            format-muted = "󰖁";
            format-icons = {
              default = ["󰕿" "󰖀" "󰕾"];
            };
            on-click = "pamixer -t";
            on-scroll-up = "pamixer -i 2";
            on-scroll-down = "pamixer -d 2";
            on-click-right = "pavucontrol";
            tooltip-format = "{desc} - {volume}%";
            scroll-step = 2;
          };

          "battery" = {
            bat = "BAT0";
            adapter = "AC";
            interval = 30;
            states = {
              warning = 20;
              critical = 10;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󰚥 {capacity}%";
            format-full = "󰁹 {capacity}%";
            format-alt = "{time}";
            format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          };

          "mpris" = {
            format = "{player_icon} {title}";
            format-paused = "⏸ {title}";
            format-stopped = "󰝛";
            max-length = 50;
            player-icons = {
              default = "▶";
              spotify = "󰓇";
              firefox = "󰈹";
              chromium = "󰊯";
            };
            status-icons = {
              paused = "⏸";
            };
            tooltip-format = "{title} - {artist}";
          };
        };
      };

      style = let
        fonts = config.stylix.fonts;
      in ''
        * {
          border: none;
          border-radius: 8px;
          font-size: 12px;
          min-height: 0;
          font-family: "${fonts.sansSerif.name}", sans-serif;
        }

        window#waybar {
          background: transparent;
          color: #ebdbb2;
        }

        window#waybar > box {
            background: transparent;
            border: none;
            box-shadow: none;
            padding: 0;
            margin: 0px 4px 0px 4px;
        }

        #workspaces button {
            padding: 0 10px;
            background: rgba(60, 56, 54, 0.6);
            color: #a89984;
            border: 2px solid #5E5851;
            border-radius: 8px;
            margin: 4px 2px;
            transition: all 0.3s ease-in-out;
            font-weight: bold;
            min-width: 40px;
            box-shadow: none;
        }

        #workspaces button.active {
            background: rgba(127, 160, 147, 0.4);
            color: #7FA093;
            border-color: #80A294;
            box-shadow: 0 2px 8px rgba(127, 160, 147, 0.4);
        }

        #workspaces button.urgent {
          background: rgba(204, 36, 29, 0.3);
          color: #cc241d;
          border-color: #cc241d;
        }

        #workspaces button:hover {
            background: rgba(80, 73, 69, 0.8);
            border-color: #80A294;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        }

        #tray,
        #cpu,
        #memory,
        #network,
        #pulseaudio,
        #backlight,
        #battery,
        #clock,
        #mpris {
          padding: 0 12px;
          margin: 4px 2px;
          background: rgba(60, 56, 54, 0.6);
          border: 2px solid #5E5851;
          border-radius: 8px;
          color: #ebdbb2;
          font-weight: bold;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        #mpris {
          background: rgba(60, 56, 54, 0.6);
          border-color: #5E5851;
          color: #7FA093;
          min-width: 200px;
          box-shadow: 0 2px 8px rgba(127, 160, 147, 0.2);
        }

        #battery.warning {
          background: rgba(214, 93, 14, 0.3);
          border-color: #d65d0e;
          color: #fe8019;
        }

        #battery.critical {
          background: rgba(204, 36, 29, 0.3);
          border-color: #cc241d;
          color: #fb4934;
          animation: blink 2s infinite;
        }

        #battery.charging {
          background: rgba(152, 151, 26, 0.3);
          border-color: #98971a;
          color: #b8bb26;
        }

        #network.disconnected {
          background: rgba(204, 36, 29, 0.3);
          border-color: #cc241d;
          color: #fb4934;
        }

        #pulseaudio.muted {
          background: rgba(102, 92, 84, 0.3);
          border-color: #665c54;
          color: #a89984;
        }

        /* Animation matching Hyprland smoothness */
        @keyframes blink {
          0% {
            opacity: 1;
            border-color: #cc241d;
          }
          100% {
            opacity: 1;
            border-color: #cc241d;
          }
          50% {
            opacity: 0.6;
            border-color: #fb4934;
          }
        }

        /* Tooltip styling */
        tooltip {
          background: rgba(40, 40, 40, 0.95);
          border: 2px solid #80A294;
          border-radius: 8px;
          color: #ebdbb2;
          padding: 12px;
          box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
        }

        tooltip label {
          color: #ebdbb2;
          font-size: 11px;
        }

        /* Special hover effects */
        #tray > *:hover,
        #cpu:hover,
        #memory:hover,
        #network:hover,
        #pulseaudio:hover,
        #backlight:hover,
        #battery:hover,
        #clock:hover,
        #mpris:hover {
          background: rgba(80, 73, 69, 0.8);
          border-color: #80A294;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        }
      '';
    };

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

    xdg.configFile."waybar/style.css".enable = true;

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

      xdg-utils

      grim
      swappy
      sway-contrib.grimshot
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
          "inode/directory" = ["org.kde.dolphin.desktop"];
        };
      };
    };
  };
}
